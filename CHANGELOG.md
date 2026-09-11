# Changelog

Newest first. Each entry says what changed and where it came from, so the next audit can see what was tried.

## 2026-09-11 (second release)

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
