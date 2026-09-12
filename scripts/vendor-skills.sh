#!/usr/bin/env bash
# Vendors third-party skills into config/.claude/skills/ at pinned commits, with their licences.
# Re-run to refresh. To upgrade a skill, change its commit in the table and re-run.
# Each vendored skill gets an UPSTREAM.md (source, commit, licence) which verify.sh uses to
# tell vendored content from ours.
set -euo pipefail
cd "$(dirname "$0")/.."

# name | owner/repo | commit | path in repo | files to drop (optional, space separated)
TABLE='
supabase-postgres-best-practices|supabase/agent-skills|8331f910845103c08d51f6ca1d86ebb7d1f745e3|skills/supabase-postgres-best-practices|
supabase|supabase/agent-skills|8331f910845103c08d51f6ca1d86ebb7d1f745e3|skills/supabase|
vercel-react-best-practices|vercel-labs/agent-skills|063bee94c3f4df8453406c830b0a7df0f2860278|skills/react-best-practices|README.md metadata.json
stripe-best-practices|stripe/ai|583467aab18cc7113dcd2c2e20028fe73c26eaa3|skills/stripe-best-practices|
verification-before-completion|obra/superpowers|b36e0829c6d0140e93cfef2ca599b1b07d4a7797|skills/verification-before-completion|
systematic-debugging|obra/superpowers|b36e0829c6d0140e93cfef2ca599b1b07d4a7797|skills/systematic-debugging|
'

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

printf '%s\n' "$TABLE" | grep -v '^[[:space:]]*$' | while IFS='|' read -r name repo sha path drop; do
  dir="$TMP/$(printf '%s' "$repo" | tr / _)"
  if [ ! -d "$dir" ]; then
    git clone -q --depth 1 "https://github.com/$repo" "$dir"
  fi
  if [ "$(git -C "$dir" rev-parse HEAD)" != "$sha" ]; then
    git -C "$dir" fetch -q --depth 1 origin "$sha" && git -C "$dir" checkout -q "$sha" \
      || { echo "WARNING: $repo could not be checked out at $sha; using $(git -C "$dir" rev-parse HEAD). Update the table." >&2; }
  fi
  [ -d "$dir/$path" ] || { echo "ERROR: $repo has no $path at $sha" >&2; exit 1; }
  dest="config/.claude/skills/$name"
  rm -rf "$dest"
  cp -R "$dir/$path" "$dest"
  for f in $drop; do rm -f "$dest/$f"; done
  licence="see SKILL.md frontmatter"
  if [ -f "$dir/LICENSE" ]; then cp "$dir/LICENSE" "$dest/LICENSE"; licence="LICENSE (copied from the repository root)"; fi
  {
    echo "# Upstream"
    echo
    echo "Vendored by scripts/vendor-skills.sh. Do not edit files in this directory; change the table in that script and re-run it."
    echo
    echo "- Source: https://github.com/$repo/tree/$sha/$path"
    echo "- Commit: $sha"
    echo "- Licence: $licence"
    echo "- Vendored: $(date -u +%Y-%m-%d)"
    [ -n "$drop" ] && echo "- Dropped from the copy: $drop (compiled or repository-only files not referenced by SKILL.md)"
  } > "$dest/UPSTREAM.md"
  echo "vendored $name from $repo@${sha:0:7}"
done
