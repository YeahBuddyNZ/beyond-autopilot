# Adding to Beyond Autopilot

This repo is the single source for the config and the audit. Every project that installs it gets whatever is on `main`, so changes here are changes everywhere. That is the point, and also the reason to be careful.

## Where things go

| You want to | Edit |
|---|---|
| Add or change a rule every project should follow | `config/CLAUDE.md` |
| Make a command silent, one-tap, or blocked | `config/.claude/settings.json` |
| Add a platform's MCP tools | `config/.claude/settings.json` (both `mcp__claude_ai_<Server>__*` and `mcp__<server>__*` spellings) |
| Enforce something rather than instruct it | A new hook under `config/.claude/hooks/`, wired in `settings.json` |
| Add a repeatable procedure | A new command under `config/.claude/commands/` |
| Change how the audit works | `config/.claude/commands/audit.md` |
| Change how install works | `install.sh` and `docs/INSTALL.md` |
| Add a "Blocked" promise to the README | A rule in `bash-guard.js` or `sql-guard.js` with a test, then the deny list, then `SECURITY.md` |

Do not add a `## Project` section to `config/CLAUDE.md`. That is filled in per target repo.

After any change under `config/`, run `bash scripts/sync-root.sh` so this repo's own installed copy matches, and bump `VERSION` to today's date. `verify.sh` fails if the root copy has drifted.

## Before you push

Run the verify script from the repo root. It is exactly what CI runs on every pull request, so if it passes here the install will pass everywhere.

```
bash scripts/verify.sh
```

It checks that `settings.json` parses, runs both guard test suites in `tests/`, lints `install.sh`, checks every command file has frontmatter, scans for em dashes, checks the root copy matches `config/`, and runs the installer end to end against a tarball of your working tree into a scratch directory that already has a `CLAUDE.md`, a `settings.json` and an eval log, then runs it a second time to prove a re-run keeps what is yours.

If you change a guard, add a case to its test file first and watch it fail, then fix the guard. Note that sessions on this repo run the guards too, so a guard bug can block your own commands; the file tools (Edit, Write) are not gated by the shell guard and are the way out.

## Changelog

Every change under `config/` or to `install.sh` gets a line in `CHANGELOG.md` under today's date, saying what changed and **where it came from**: which project, which audit, what went wrong. A future audit reads this to see what was tried.

## Style

- New Zealand English. No em dashes anywhere, including code comments and commit messages.
- Instructions in `config/CLAUDE.md` are short and imperative. If a rule needs a paragraph, it probably wants to be a hook or a check instead.
- Prefer enforcement over instruction. A permission or a hook the AI cannot skip beats a sentence it might forget.

## Releasing

`main` is what installs. Open a pull request, run the checks above, merge. There is no version number; the changelog date is the version. To pin a repo to a point in time, install with `AUTOPILOT_REF=<tag or branch>`.
