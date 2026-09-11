#!/usr/bin/env bash
# The checks a contributor runs before pushing, and the checks CI runs on every PR.
# Usage: bash scripts/verify.sh
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
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

step "installer end to end against this tree"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git ls-files -z --cached --others --exclude-standard | tar --null -T - --transform 's,^,beyond-autopilot-main/,' -czf "$TMP/src.tar.gz"
mkdir -p "$TMP/target/.claude"
printf '# Existing project\n\nRun with npm start.\n' > "$TMP/target/CLAUDE.md"
printf '{"permissions":{}}\n' > "$TMP/target/.claude/settings.json"
if AUTOPILOT_ARCHIVE="$TMP/src.tar.gz" bash install.sh "$TMP/target" >"$TMP/install.log" 2>&1; then
  for f in .claude/settings.json .claude/hooks/sql-guard.js .claude/commands/audit.md .claude/commands/plan.md .claude/commands/review.md .claude/commands/lesson.md CLAUDE.md .claude/settings.json.bak; do
    [ -f "$TMP/target/$f" ] || bad "installer did not produce $f"
  done
  grep -q 'Run with npm start' "$TMP/target/CLAUDE.md" || bad "existing CLAUDE.md content was not merged"
  grep -q '^# Beyond Autopilot' "$TMP/target/CLAUDE.md" || bad "installed CLAUDE.md is not the payload"
  # a second run must refresh the rules but keep everything the user put in the Project section
  printf -- '- Name: Verify Fixture\n- Stack: none\n' >> "$TMP/target/CLAUDE.md"
  AUTOPILOT_ARCHIVE="$TMP/src.tar.gz" bash install.sh "$TMP/target" >>"$TMP/install.log" 2>&1 || bad "second install run failed"
  [ "$(grep -c 'Existing project notes' "$TMP/target/CLAUDE.md")" = "1" ] || bad "re-run did not keep exactly one merged-notes block"
  grep -q 'Name: Verify Fixture' "$TMP/target/CLAUDE.md" || bad "re-run lost the filled-in Project section"
  grep -q 'Run with npm start' "$TMP/target/CLAUDE.md" || bad "re-run lost the merged notes"
  [ "$(grep -c '^## Project' "$TMP/target/CLAUDE.md")" = "1" ] || bad "re-run duplicated the Project heading"
  ok
else
  cat "$TMP/install.log"; bad "install.sh failed"
fi

printf '\n'
if [ "$fail" = "0" ]; then echo "All checks passed."; else echo "Some checks failed."; exit 1; fi
