#!/usr/bin/env bash
# Beyond Autopilot for Claude Code: installer
#
# Installs the Beyond Autopilot config (permissions, SQL guard, /audit command,
# base CLAUDE.md) into a repo. Safe to re-run: it overwrites its own files and
# keeps anything else you have in .claude/ and CLAUDE.md.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/YeahBuddyNZ/autopilot-config-into-a-cloud/main/install.sh | bash
#   curl -sL https://raw.githubusercontent.com/YeahBuddyNZ/autopilot-config-into-a-cloud/main/install.sh | bash -s -- /path/to/repo
#
# Environment:
#   AUTOPILOT_REPO   GitHub owner/repo to pull from (default YeahBuddyNZ/autopilot-config-into-a-cloud)
#   AUTOPILOT_REF    branch or tag to install (default main)
#   AUTOPILOT_ARCHIVE  path to a local .tar.gz of this repo to install from instead of downloading

set -euo pipefail

REPO="${AUTOPILOT_REPO:-YeahBuddyNZ/autopilot-config-into-a-cloud}"
REF="${AUTOPILOT_REF:-main}"
TARGET="${1:-.}"

say()  { printf '%s\n' "$*"; }
die()  { printf 'install.sh: %s\n' "$*" >&2; exit 1; }

for tool in curl tar node; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is required and was not found on PATH"
done

[ -d "$TARGET" ] || die "target directory does not exist: $TARGET"
TARGET="$(cd "$TARGET" && pwd)"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [ -n "${AUTOPILOT_ARCHIVE:-}" ]; then
  [ -f "$AUTOPILOT_ARCHIVE" ] || die "AUTOPILOT_ARCHIVE does not exist: $AUTOPILOT_ARCHIVE"
  say "Beyond Autopilot: installing from $AUTOPILOT_ARCHIVE into $TARGET"
  cp "$AUTOPILOT_ARCHIVE" "$TMP/src.tar.gz"
else
  say "Beyond Autopilot: installing from $REPO@$REF into $TARGET"
  # Pull the archive. The wildcard pattern means this keeps working if the repo is renamed.
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$REF.tar.gz" -o "$TMP/src.tar.gz" \
    || die "could not download https://github.com/$REPO/archive/refs/heads/$REF.tar.gz"
fi
mkdir -p "$TMP/payload"
tar -xzf "$TMP/src.tar.gz" -C "$TMP/payload" --strip-components=2 --wildcards '*/config/*' \
  || die "archive did not contain a config/ directory"

[ -f "$TMP/payload/.claude/settings.json" ] || die "payload is missing .claude/settings.json"
[ -f "$TMP/payload/CLAUDE.md" ] || die "payload is missing CLAUDE.md"

# Keep a copy of a settings.json we are about to replace, if it differs.
if [ -f "$TARGET/.claude/settings.json" ] && ! cmp -s "$TARGET/.claude/settings.json" "$TMP/payload/.claude/settings.json"; then
  cp "$TARGET/.claude/settings.json" "$TARGET/.claude/settings.json.bak"
  say "  kept your previous .claude/settings.json as .claude/settings.json.bak"
fi

# CLAUDE.md handling.
#   Re-run (the existing file is ours): the rules above "## Project" are refreshed from the payload,
#   everything from "## Project" to the end is kept exactly as you had it.
#   First run over someone else's CLAUDE.md: its content is appended under the Project section.
if [ -f "$TARGET/CLAUDE.md" ]; then
  if grep -q '^# Beyond Autopilot' "$TARGET/CLAUDE.md"; then
    if grep -q '^## Project' "$TARGET/CLAUDE.md"; then
      {
        sed '/^## Project/,$d' "$TMP/payload/CLAUDE.md"
        sed -n '/^## Project/,$p' "$TARGET/CLAUDE.md"
      } > "$TMP/payload/CLAUDE.md.merged"
      mv "$TMP/payload/CLAUDE.md.merged" "$TMP/payload/CLAUDE.md"
      say "  refreshed the rules in CLAUDE.md and kept your Project section"
    fi
  else
    {
      cat "$TMP/payload/CLAUDE.md"
      printf '\n### Existing project notes (merged by the installer, tidy these up)\n\n'
      cat "$TARGET/CLAUDE.md"
    } > "$TMP/payload/CLAUDE.md.merged"
    mv "$TMP/payload/CLAUDE.md.merged" "$TMP/payload/CLAUDE.md"
    say "  merged your existing CLAUDE.md into the Project section"
  fi
fi

mkdir -p "$TARGET/.claude/hooks" "$TARGET/.claude/commands"
cp -R "$TMP/payload/.claude/." "$TARGET/.claude/"
cp "$TMP/payload/CLAUDE.md" "$TARGET/CLAUDE.md"

# Verify what we just installed.
node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$TARGET/.claude/settings.json" \
  || die "installed settings.json does not parse"
if printf '{"tool_input":{"query":"delete from public.t"}}' | node "$TARGET/.claude/hooks/sql-guard.js" 2>/dev/null; then
  die "SQL guard did not block a bare DELETE; something is wrong with the hook"
fi

say "  installed:"
say "    CLAUDE.md"
(cd "$TMP/payload" && find .claude -type f | sort | sed 's/^/    /')
say ""
say "Next:"
say "  1. Fill in the '## Project' section at the bottom of CLAUDE.md."
say "  2. Commit and push, then merge to your default branch."
say "  3. Start a fresh Claude Code session. Cloud sessions load the config on clone."
