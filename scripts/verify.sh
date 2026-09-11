#!/usr/bin/env bash
# The checks a contributor runs before pushing, and the checks CI runs on every PR.
# Usage: bash scripts/verify.sh
set -euo pipefail
cd "$(dirname "$0")/.."

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

step "every command file has frontmatter with a description"
for f in config/.claude/commands/*.md; do
  head -1 "$f" | grep -q '^---$' && grep -q '^description:' "$f" || bad "$f is missing frontmatter or description"
done
ok

step "no em dashes anywhere"
if LC_ALL=C grep -rnP '\xE2\x80\x94' --include='*.md' --include='*.js' --include='*.json' --include='*.sh' --include='*.yml' . --exclude-dir=.git; then
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
git ls-files -z --cached --others --exclude-standard | tar --null -T - --transform 's,^,beyond-autopilot-main/,' -czf "$TMP/src.tar.gz"
mkdir -p "$TMP/target/.claude"
printf '# Existing project\n\nRun with npm start.\n' > "$TMP/target/CLAUDE.md"
printf '{"permissions":{}}\n' > "$TMP/target/.claude/settings.json"
if AUTOPILOT_ARCHIVE="$TMP/src.tar.gz" bash install.sh "$TMP/target" >"$TMP/install.log" 2>&1; then
  for f in .claude/settings.json .claude/hooks/sql-guard.js .claude/hooks/bash-guard.js .claude/hooks/session-check.js \
           .claude/commands/audit.md .claude/commands/plan.md .claude/commands/review.md .claude/commands/lesson.md \
           .claude/autopilot.json docs/ai-process-audit/eval-log.md docs/ai-process-audit/lessons.md docs/plans/README.md \
           CLAUDE.md .claude/settings.json.bak; do
    [ -f "$TMP/target/$f" ] || bad "installer did not produce $f"
  done
  grep -q "\"version\": \"$(cat VERSION)\"" "$TMP/target/.claude/autopilot.json" || bad "stamp does not carry the VERSION file's value"
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
