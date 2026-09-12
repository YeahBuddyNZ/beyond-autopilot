Status: closed

Closed 2026-09-12. Differences from the plan: the vendoring script clones with git instead of downloading archives, because the session proxy only serves public repos through git. The Vercel skill's compiled AGENTS.md was kept rather than dropped because SKILL.md points at it. The base CLAUDE.md landed at 61 lines. The installer gained an upgrade step that removes the superseded command files, which the plan had not foreseen; a verify fixture now covers it.

# Fold in lessons from Beyond's projects and the skills research

## Task
Turn the lessons written down across 23 of Beyond's repositories, plus the skills research, into the payload so every new project starts with them.

## What exists
Two agent reports over 23 repos (11 and 12), one over four skills collections and the Claude Code skills docs. Findings that recur in 3 or more repos are candidates for the base; project-specific ones are examples for the Project section. The payload has four commands under `.claude/commands/`; the docs say commands and skills are the same mechanism and skills support supporting files.

## Acceptance criteria
1. `config/CLAUDE.md` gains only rules that recur in 3 or more repos or trace to a shipped defect, and stays under 100 lines.
2. Platform traps (Supabase, Vercel, Render, Astro, Next.js, Resend) live in one retrievable skill, `beyond-traps`, not in the always-on file.
3. The four commands become skills under `.claude/skills/<name>/SKILL.md` with the same slash names; `/plan`, `/lesson` and `/audit` are user-invoked only.
4. Six third-party skills are vendored with their MIT licence files and a pinned upstream commit, refreshable by one script.
5. `verify.sh` checks every skill has frontmatter with a description under 1,536 characters, a body under 500 lines, and a LICENSE where vendored.
6. Installer, session check, README, USAGE, INSTALL, CONTRIBUTING, CHANGELOG, VERSION and this repo's root copy all reflect the change; `bash scripts/verify.sh` passes.
7. The git author email conflict between repos is resolved with one rule.

## Steps
1. Vendor skills with `scripts/vendor-skills.sh`; verify: directories exist with LICENSE.
2. Write `beyond-traps` skill from the reports; verify: under 500 lines, no secrets, no em dashes.
3. Migrate commands to skills, improve descriptions and add the lesson promotion rule and review phases; verify: `/plan` etc. listed by the session.
4. Update `config/CLAUDE.md`; verify: line count.
5. Update verify.sh, install.sh, docs; run `bash scripts/sync-root.sh && bash scripts/verify.sh`.

## Risks
Always-on context grows by ten skill descriptions. Mitigation: descriptions kept tight; audit the total. Vendored content may drift from upstream. Mitigation: pinned commits and a refresh script.

## Out of scope
Fixing the two housekeeping findings in other repos (a committed temporary password, an embedded publishable key). Reported to the owner, not touched.
