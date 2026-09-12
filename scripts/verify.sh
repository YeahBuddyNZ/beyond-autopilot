#!/usr/bin/env bash
# The checks a contributor runs before pushing, and the checks CI runs on every PR.
# Usage: bash scripts/verify.sh
set -euo pipefail
cd "$(dirname "$0")/.."
trap 'echo "verify.sh: aborted at line $LINENO (a command failed outside a check)"; exit 1' ERR

fail=0
TMP_ROOTCHECK="$(mktemp)"
trap 'rm -f "$TMP_ROOTCHECK"' EXIT
step() { printf '\n== %s\n' "$*"; }
ok()   { printf '   ok\n'; }
bad()  { printf '   FAIL: %s\n' "$*"; fail=1; }

step "settings.json parses"
node -e 'JSON.parse(require("fs").readFileSync("config/.claude/settings.json","utf8"))' && ok || bad "config/.claude/settings.json is not valid JSON"

step "SQL guard tests"
node --test tests/*.test.js && ok || bad "tests/ failed"

step "install.sh syntax"
bash -n install.sh && ok || bad "install.sh has a syntax error"

step "every skill has frontmatter, a description under 1,536 characters, and a body under 500 lines"
for f in config/.claude/skills/*/SKILL.md; do
  head -1 "$f" | grep -q '^---$' || bad "$f does not start with frontmatter"
  desc="$(awk '/^---$/{c++; next} c==1 && /^description:/{sub(/^description:[ ]*/,""); print; exit}' "$f")"
  [ -n "$desc" ] || bad "$f has no description"
  [ "${#desc}" -le 1536 ] || bad "$f description is ${#desc} characters (limit 1536)"
  [ "$(wc -l < "$f")" -le 500 ] || bad "$f is $(wc -l < "$f") lines (limit 500; move detail into references/)"
done
[ -d config/.claude/commands ] && bad "config/.claude/commands still exists; commands have moved to skills"
ok

step "vendored skills carry UPSTREAM.md and a licence"
for d in config/.claude/skills/*/; do
  n="$(basename "$d")"
  if [ -f "$d/UPSTREAM.md" ]; then
    grep -q '^- Commit: [0-9a-f]\{40\}$' "$d/UPSTREAM.md" || bad "$n UPSTREAM.md has no pinned commit"
    [ -f "$d/LICENSE" ] || grep -qi '^license:' "$d/SKILL.md" || bad "$n has no LICENSE file and no license in its frontmatter"
    grep -q "^| $n |" THIRD-PARTY-NOTICES.md || bad "$n is not listed in THIRD-PARTY-NOTICES.md"
  fi
done
ok

step "no em dashes in anything we wrote (vendored skills are excluded)"
VENDORED_RE="$( (cd config/.claude/skills && for d in */; do [ -f "$d/UPSTREAM.md" ] && printf '%s|' "${d%/}"; done) | sed 's/|$//')"
if LC_ALL=C grep -rnP '\xE2\x80\x94' --include='*.md' --include='*.js' --include='*.json' --include='*.sh' --include='*.yml' . --exclude-dir=.git \
   | grep -vE "^\./(config/)?\.claude/skills/(${VENDORED_RE:-__none__})/" | grep .; then
  bad "em dash found (see above)"
else
  ok
fi

step "the repo runs the payload it ships (root .claude and CLAUDE.md rules match config/)"
[ -d .claude ] || bad "no .claude/ at the repo root (run bash scripts/sync-root.sh)"
(cd config/.claude && find . -type f) | while read -r f; do
  cmp -s "config/.claude/$f" ".claude/$f" || echo "   FAIL: root .claude/${f#./} differs from config/ (run bash scripts/sync-root.sh)"
done | tee "$TMP_ROOTCHECK"
[ -s "$TMP_ROOTCHECK" ] && fail=1
if ! diff <(sed '/^## Project/,$d' config/CLAUDE.md) <(sed '/^## Project/,$d' CLAUDE.md) >/dev/null; then
  bad "root CLAUDE.md rules differ from config/CLAUDE.md above '## Project' (run bash scripts/sync-root.sh)"
fi
grep -q '^## Project' CLAUDE.md && ! grep -q 'Fill in per repo' CLAUDE.md || bad "root CLAUDE.md Project section is missing or still the template"
[ -f .claude/autopilot.json ] || bad "root .claude/autopilot.json is missing (run bash scripts/sync-root.sh)"
[ "$fail" = "0" ] && ok

step "installer end to end against this tree"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP" "$TMP_ROOTCHECK"' EXIT
git ls-files -z --cached --others --exclude-standard | while IFS= read -r -d '' f; do [ -e "$f" ] && printf '%s\0' "$f"; done | tar --null -T - --transform 's,^,beyond-autopilot-main/,' -czf "$TMP/src.tar.gz"
mkdir -p "$TMP/target/.claude/commands"
printf -- '---\ndescription: old\n---\nold plan command\n' > "$TMP/target/.claude/commands/plan.md"
printf '# Existing project\n\nRun with npm start.\n' > "$TMP/target/CLAUDE.md"
printf '{"permissions":{}}\n' > "$TMP/target/.claude/settings.json"
if AUTOPILOT_ARCHIVE="$TMP/src.tar.gz" bash install.sh "$TMP/target" >"$TMP/install.log" 2>&1; then
  for f in .claude/settings.json .claude/hooks/sql-guard.js .claude/hooks/bash-guard.js .claude/hooks/session-check.js \
           .claude/skills/audit/SKILL.md .claude/skills/audit/references/appendices.md .claude/skills/plan/SKILL.md .claude/skills/review/SKILL.md .claude/skills/lesson/SKILL.md \
           .claude/skills/beyond-traps/SKILL.md .claude/skills/supabase/SKILL.md .claude/skills/supabase-postgres-best-practices/SKILL.md \
           .claude/skills/vercel-react-best-practices/SKILL.md .claude/skills/stripe-best-practices/SKILL.md \
           .claude/skills/verification-before-completion/SKILL.md .claude/skills/systematic-debugging/SKILL.md \
           .claude/autopilot.json docs/ai-process-audit/eval-log.md docs/ai-process-audit/lessons.md docs/plans/README.md \
           CLAUDE.md .claude/settings.json.bak; do
    [ -f "$TMP/target/$f" ] || bad "installer did not produce $f"
  done
  grep -q "\"version\": \"$(cat VERSION)\"" "$TMP/target/.claude/autopilot.json" || bad "stamp does not carry the VERSION file's value"
  [ ! -e "$TMP/target/.claude/commands/plan.md" ] || bad "installer left a superseded .claude/commands/plan.md in place"
  printf '| 2026-01-01 | keep me | | | | | | | | |\n' >> "$TMP/target/docs/ai-process-audit/eval-log.md"
  CLAUDE_PROJECT_DIR="$TMP/target" node "$TMP/target/.claude/hooks/session-check.js" | grep -q 'still the template' || bad "session check did not warn about an unfilled Project section"
  grep -q 'Run with npm start' "$TMP/target/CLAUDE.md" || bad "existing CLAUDE.md content was not merged"
  grep -q '^# Beyond Autopilot' "$TMP/target/CLAUDE.md" || bad "installed CLAUDE.md is not the payload"
  # a second run must refresh the rules but keep everything the user put in the Project section
  printf -- '- Name: Verify Fixture\n- Stack: none\n' >> "$TMP/target/CLAUDE.md"
  AUTOPILOT_ARCHIVE="$TMP/src.tar.gz" bash install.sh "$TMP/target" >>"$TMP/install.log" 2>&1 || bad "second install run failed"
  [ "$(grep -c 'Existing project notes' "$TMP/target/CLAUDE.md")" = "1" ] || bad "re-run did not keep exactly one merged-notes block"
  grep -q 'Name: Verify Fixture' "$TMP/target/CLAUDE.md" || bad "re-run lost the filled-in Project section"
  grep -q 'Run with npm start' "$TMP/target/CLAUDE.md" || bad "re-run lost the merged notes"
  [ "$(grep -c '^## Project' "$TMP/target/CLAUDE.md")" = "1" ] || bad "re-run duplicated the Project heading"
  grep -q 'keep me' "$TMP/target/docs/ai-process-audit/eval-log.md" || bad "re-run overwrote the eval log"
  ok
else
  cat "$TMP/install.log"; bad "install.sh failed"
fi

printf '\n'
if [ "$fail" = "0" ]; then echo "All checks passed."; else echo "Some checks failed."; exit 1; fi
