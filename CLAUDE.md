# Working rules for this repo

This repo is the source of the Claude Code autopilot config and the AI process audit that get installed into other projects. It is not itself a project that uses them.

- The installable payload lives under `config/`. Do not move it to the root; the payload's deny rules would then stop this repo from editing itself.
- After any change under `config/`, check `config/.claude/settings.json` parses as JSON and `config/.claude/hooks/sql-guard.js` still blocks a bare `delete from` (see README).
- Any change to `config/` gets a line in `CHANGELOG.md` with where it came from.
- Do not add a `## Project` section to `config/CLAUDE.md` here. That is filled in per target repo.
- New Zealand English. No em dashes anywhere, including code comments and commit messages.
- Short replies. Lead with what you did.
