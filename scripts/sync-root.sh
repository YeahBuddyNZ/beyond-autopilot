#!/usr/bin/env bash
# Refresh this repo's own installed copy of the payload from config/.
# This repo runs what it ships: .claude/ at the root is the installed copy, config/ is the source.
# verify.sh fails if the two drift, so run this after any change under config/.
set -euo pipefail
cd "$(dirname "$0")/.."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git ls-files -z --cached --others --exclude-standard | while IFS= read -r -d '' f; do [ -e "$f" ] && printf '%s\0' "$f"; done | tar --null -T - --transform 's,^,beyond-autopilot-main/,' -czf "$TMP/src.tar.gz"
AUTOPILOT_ARCHIVE="$TMP/src.tar.gz" bash install.sh .
