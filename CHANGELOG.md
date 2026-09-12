# Changelog

Newest first. Each entry says what changed and where it came from, so the next audit can see what was tried. The date of the newest payload entry is the value in `VERSION`.

## 2026.09.12

Source: owner request for a statement of what kinds of skill belong in the payload.

- `docs/SKILLS.md`: the five kinds of thing mistaken for a skill and where each belongs, the four kinds this payload carries and why, the kinds deliberately left out, the bar for adding one, and where each kind lives. Docs only; no payload change.

Source: finalising the release.

- The installer's archive URL now works for a branch, a tag or a commit, so `AUTOPILOT_REF=v2026.09.12` pins a project to a release as the docs already claimed. Found while tagging the first release.
- The install stamp's source label no longer glues "local archive" onto a temp path; `scripts/sync-root.sh` labels this repo's own stamp as coming from `config/`. Covered by `verify.sh`.
- First release tag `v2026.09.12`, created by the owner from the Releases page. Sessions cannot create tags; recorded in `docs/decisions.md`.

Source: the instruction files, notes and commit history of 23 Beyond repositories (two read-only surveys), and a survey of the Claude Code skills docs and four skills collections.

- Base rules (`config/CLAUDE.md`, now 61 lines): never invent a fact; never close a business, legal, clinical or financial question; RLS written with the table and verified from a second tenant; connector-applied migrations must be committed; service role key never in a client bundle; build-time env vars need a rebuild and must fail closed; confirm the effect of a deploy, not the gesture; git author stays as configured; green tests are necessary not sufficient; make a new test fail before trusting it; never weaken a check to get green; a route with no entrance is not finished; sweep the codebase when writing a rule; money is integer cents with GST at the total; commit messages say what was verified; decisions are superseded, not worked around. Each recurred in three or more repos or traces to a defect that shipped.
- `beyond-traps` skill: the platform traps from those repos with symptom, fix and source, organised by Supabase, Vercel, Render, Astro, Next.js, CI, cloud sessions, and NZ money and claims.
- Commands moved to skills (`.claude/skills/<name>/SKILL.md`), the current Claude Code mechanism. Descriptions rewritten as triggers with positive and negative cases. `/plan`, `/lesson` and `/audit` are user-invoked only. `/review` gained blast radius, revert-the-fix test checks, reachability and an adversarial pass. `/lesson` gained a sweep step and a promotion rule (a lesson becomes a rule only with a passing check, a named failure and a ruled-out alternative). The audit's appendices moved to `references/appendices.md` to keep the skill under 500 lines.
- Six third-party skills vendored at pinned commits with licences, via `scripts/vendor-skills.sh`: `supabase`, `supabase-postgres-best-practices`, `vercel-react-best-practices`, `stripe-best-practices`, `verification-before-completion`, `systematic-debugging`. Listed in `THIRD-PARTY-NOTICES.md`.
- `docs/PROJECT-SECTION.md`: what a good Project section holds, from the 23 repos.
- `verify.sh` now checks every skill's frontmatter, description length and body length, and that vendored skills carry a pinned commit and a licence. The em dash scan excludes vendored text.

Source: the self-audit (`docs/ai-process-audit/AI-PROCESS-AUDIT.md`), recommendations R1 to R5 and the stop-doing list.

- The repo installs its own payload (R1). Root `.claude/` and the rules in `CLAUDE.md` are the installed copy; `scripts/sync-root.sh` refreshes them and `verify.sh` fails on drift.
- Shell guard (R2): `config/.claude/hooks/bash-guard.js`, fail-closed, wired to the Bash tool, with a test suite. Reuses the SQL guard's rules for SQL on a command line. Two false positives were found and fixed within the first hour of it being live on this repo (bare `env`, backticks inside heredocs); both are test cases now.
- Version and self-check (R3): `VERSION` (date-based), stamped into `.claude/autopilot.json` by the installer; `session-check.js` runs at session start and reports the version, missing guards, and an unfilled Project section.
- Measurement (R4): the payload ships `docs/ai-process-audit/eval-log.md` and `lessons.md` templates and `docs/plans/README.md`, created once and never overwritten; `/review` appends an eval-log row when it finishes; the golden task suite is adopted for this repo.
- Knowledge (R5): `docs/ai-process-audit/lessons.md` and `docs/decisions.md` record what this session learned and decided.
- Stop-doing list: the full cloud install message now lives only in `docs/INSTALL.md`; what the guards block is listed once, in `SECURITY.md`; the installer prints what it installed instead of the docs listing it.

## 2026-09-11 (second release)

- Ran `/audit quick` on this repo and committed the output under `docs/ai-process-audit/` as a worked example. Score 5.1. Top finding: the repo does not run the payload it ships. Recommendations R1 to R5 are the next work.
- Audit prompt: Quick mode now has its own word budget (main body under 2,000 words). Found while running it; Full mode's 6,000 was the only budget stated.

- Rebranded as Beyond Autopilot for Claude Code. Payload `CLAUDE.md` retitled so the installer can recognise its own file.
- Added `install.sh`: one-line installer that extracts the payload, keeps an existing `CLAUDE.md` under the Project section, backs up a replaced `settings.json`, and verifies the SQL guard before reporting success. Rename-proof extraction.
- Added three workflow commands to the payload: `/plan`, `/review` and `/lesson`, and a Workflow section in the payload `CLAUDE.md` that tells sessions when to use them. Source: the audit's own principles (durable plans, independent verification, closed feedback loops), applied to the base.
- Added `tests/sql-guard.test.js` (allowed and blocked cases, hidden keywords, fails closed) and `scripts/verify.sh`, which also runs the installer end to end against the working tree. GitHub Actions runs it on every pull request.
- Added `SECURITY.md`, a pull request template, and `.editorconfig`.
- Replaced the docs with a full set: README, `docs/INSTALL.md`, `docs/USAGE.md`, `docs/AUDIT.md`, `docs/OWNER-INTAKE.md`, `docs/TROUBLESHOOTING.md`, `CONTRIBUTING.md`. `docs/INSTALL-CLOUD.md` and `docs/audit/HOW-TO-RUN.md` folded in and removed.

## 2026-09-11 (first release)

- Initial import of the Claude Code autopilot config (permissions, SQL guard hook, base CLAUDE.md) from the Git_Autopilot bundle.
- Initial import of the AI engineering process audit (v2) from the AI_Audit bundle, shipped as the `/audit` slash command inside the config payload so every repo with the config can run it.
- Owner intake questionnaire split out of the how-to into its own template.
- Install docs updated to point at this repo and the `config/` layout.
