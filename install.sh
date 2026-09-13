#!/usr/bin/env bash
# Beyond Autopilot for Claude Code: installer
#
# Installs the Beyond Autopilot config (permissions, SQL guard, /audit command,
# base CLAUDE.md) into a repo. Safe to re-run: it overwrites its own files and
# keeps anything else you have in .claude/ and CLAUDE.md.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/YeahBuddyNZ/beyond-autopilot/main/install.sh | bash
#   curl -sL https://raw.githubusercontent.com/YeahBuddyNZ/beyond-autopilot/main/install.sh | bash -s -- /path/to/repo
#
# Environment:
#   AUTOPILOT_REPO   GitHub owner/repo to pull from (default YeahBuddyNZ/beyond-autopilot)
#   AUTOPILOT_REF    branch, tag or commit to install (default main)
#   AUTOPILOT_ARCHIVE  path to a local .tar.gz of this repo to install from instead of downloading
#   AUTOPILOT_SOURCE   label written into .claude/autopilot.json (default: repo@ref, or "local archive")
#
# curl, tar and node are required. git is optional: it is used only to fall back to a clone
# when the GitHub archive host is blocked (some cloud-session proxies 403 it).

set -euo pipefail

REPO="${AUTOPILOT_REPO:-YeahBuddyNZ/beyond-autopilot}"
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

PAYLOAD_READY=""
if [ -n "${AUTOPILOT_ARCHIVE:-}" ]; then
  [ -f "$AUTOPILOT_ARCHIVE" ] || die "AUTOPILOT_ARCHIVE does not exist: $AUTOPILOT_ARCHIVE"
  say "Beyond Autopilot: installing from $AUTOPILOT_ARCHIVE into $TARGET"
  cp "$AUTOPILOT_ARCHIVE" "$TMP/src.tar.gz"
else
  say "Beyond Autopilot: installing from $REPO@$REF into $TARGET"
  # GitHub serves archive/<ref>.tar.gz for a branch, a tag or a commit. Some Claude Code
  # cloud-session proxies return 403 for that host, so if the download fails, fall back to a
  # git clone, which the same proxies serve for public repos. This is the case the first real
  # install hit; see docs/ai-process-audit/lessons.md. The wildcard extraction below survives
  # a repo rename either way.
  if ! curl -fsSL "https://github.com/$REPO/archive/$REF.tar.gz" -o "$TMP/src.tar.gz" 2>/dev/null; then
    command -v git >/dev/null 2>&1 \
      || die "could not download the archive and git is not available to fall back to a clone. In a cloud session, clone the repo and run install.sh from it."
    say "  archive download failed (a cloud proxy may block that host); falling back to a git clone"
    GIT_LFS_SKIP_SMUDGE=1 git clone -q --depth 1 "https://github.com/$REPO" "$TMP/clone" \
      || die "could not download the archive or clone https://github.com/$REPO"
    if [ "$REF" != "main" ]; then
      git -C "$TMP/clone" fetch -q --depth 1 origin "$REF" && git -C "$TMP/clone" checkout -q FETCH_HEAD \
        || die "cloned $REPO but could not check out $REF"
    fi
    [ -d "$TMP/clone/config" ] || die "clone of $REPO has no config/ directory"
    mkdir -p "$TMP/payload"
    cp -R "$TMP/clone/config/." "$TMP/payload/"
    VERSION="$(head -1 "$TMP/clone/VERSION" 2>/dev/null || true)"
    PAYLOAD_READY=1
  fi
fi
if [ -z "$PAYLOAD_READY" ]; then
  mkdir -p "$TMP/payload"
  tar -xzf "$TMP/src.tar.gz" -C "$TMP/payload" --strip-components=2 --wildcards '*/config/*' \
    || die "archive did not contain a config/ directory"
  VERSION="$(tar -xzOf "$TMP/src.tar.gz" --wildcards '*/VERSION' 2>/dev/null | head -1 || true)"
fi
[ -n "${VERSION:-}" ] || VERSION="unknown"

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

mkdir -p "$TARGET/.claude/hooks" "$TARGET/.claude/skills"
cp -R "$TMP/payload/.claude/." "$TARGET/.claude/"

# Upgrade path: earlier payloads shipped these as .claude/commands/*.md. The same names now
# live under .claude/skills/, so the old files would register each slash command twice.
# Only a file whose description matches the one we shipped is removed; a project's own command
# with the same name is kept and reported, because deleting someone else's work is not an upgrade.
ours_desc() {
  case "$1" in
    plan)   printf '%s' 'description: Write a durable implementation plan with acceptance criteria before building' ;;
    review) printf '%s' 'description: Independent review pass over a change before it is called done.' ;;
    lesson) printf '%s' 'description: Turn a correction or mistake into a durable control (a test, rule, hook or doc)' ;;
    audit)  printf '%s' 'description: Audit the AI engineering process around this repo (not the product).' ;;
  esac
}
is_ours() {
  # the command file this payload shipped, or (audit only) the original audit prompt that
  # predates the payload and was installed by hand as .claude/commands/audit.md
  grep -qF "$(ours_desc "$1")" "$2" && return 0
  [ "$1" = "audit" ] && grep -q '^# AI Engineering Process Audit' "$2" && grep -q '^## 0. Mission' "$2" && return 0
  return 1
}
for c in plan review lesson audit; do
  f="$TARGET/.claude/commands/$c.md"
  [ -f "$f" ] || continue
  if is_ours "$c" "$f"; then
    rm -f "$f" && say "  removed superseded .claude/commands/$c.md (replaced by .claude/skills/$c/)"
  else
    say "  kept .claude/commands/$c.md: it is not the one this payload shipped. Note that /$c now resolves to two files; rename or remove one."
  fi
done
rmdir "$TARGET/.claude/commands" 2>/dev/null || true
cp "$TMP/payload/CLAUDE.md" "$TARGET/CLAUDE.md"

# Everything else in the payload (docs templates: plans, eval log, lessons) is created only
# if absent. These are yours once they exist; the installer never overwrites them.
(cd "$TMP/payload" && find . -type f ! -path './.claude/*' ! -name CLAUDE.md) | while read -r rel; do
  rel="${rel#./}"
  if [ ! -e "$TARGET/$rel" ]; then
    mkdir -p "$TARGET/$(dirname "$rel")"
    cp "$TMP/payload/$rel" "$TARGET/$rel"
    say "  created $rel"
  fi
done

# Version stamp, read by the session-start check.
SOURCE="${AUTOPILOT_SOURCE:-}"
if [ -z "$SOURCE" ]; then
  if [ -n "${AUTOPILOT_ARCHIVE:-}" ]; then SOURCE="local archive"; else SOURCE="$REPO@$REF"; fi
fi
printf '{\n  "version": "%s",\n  "source": "%s",\n  "installed_at": "%s"\n}\n' \
  "$VERSION" "$SOURCE" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  > "$TARGET/.claude/autopilot.json"

# Verify what we just installed.
node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$TARGET/.claude/settings.json" \
  || die "installed settings.json does not parse"
if printf '{"tool_input":{"query":"delete from public.t"}}' | node "$TARGET/.claude/hooks/sql-guard.js" 2>/dev/null; then
  die "SQL guard did not block a bare DELETE; something is wrong with the hook"
fi
if printf '{"tool_input":{"command":"rm -rf /"}}' | node "$TARGET/.claude/hooks/bash-guard.js" 2>/dev/null; then
  die "shell guard did not block rm -rf; something is wrong with the hook"
fi

say "  installed Beyond Autopilot $VERSION:"
say "    CLAUDE.md"
(cd "$TMP/payload" && find .claude -type f | sort | sed 's/^/    /')
say "    .claude/autopilot.json"
say ""
say "Next:"
say "  1. Fill in the '## Project' section at the bottom of CLAUDE.md."
say "  2. Commit and push, then merge to your default branch."
say "  3. Start a fresh Claude Code session. Cloud sessions load the config on clone."
