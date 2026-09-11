# Working rules for this repo

This repo is the source of Beyond Autopilot for Claude Code: the config payload and the AI process audit that get installed into other projects. It is not itself a project that uses them.

- The installable payload lives under `config/`. Do not move it to the root; the payload's deny rules would then stop this repo from editing itself.
- After any change under `config/` or to `install.sh`, run the checks in `CONTRIBUTING.md`.
- Any change to `config/` or `install.sh` gets a line in `CHANGELOG.md` with where it came from.
- Do not add a `## Project` section to `config/CLAUDE.md`. That is filled in per target repo.
- Keep the docs in `docs/` in step with the payload. If a behaviour changes, its doc changes in the same commit.
- New Zealand English. No em dashes anywhere, including code comments and commit messages.
- Short replies. Lead with what you did.
