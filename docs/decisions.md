# Decisions

Short records of choices that shape this repo, so the next session does not re-argue them. Newest first. One paragraph each; if a decision needs more, it needs an ADR in a downstream repo, not here.

## 2026-09-12: The repo installs its own payload

`.claude/` at the root and the rules section of `CLAUDE.md` are the installed copy of `config/`, refreshed by `scripts/sync-root.sh`, and `verify.sh` fails if they drift. The audit found that shipping `/plan`, `/review` and `/lesson` while not having them here produced exactly the failures they prevent. Cost: the payload's deny on editing `.claude/**` and `.github/**` applies to sessions on this repo, and the guards apply to the session that edits the guards. Accepted; it caught a false positive within minutes.

## 2026-09-12: Two guards, same design

The SQL guard and the shell guard are both fail-closed PreToolUse hooks with test suites, and the shell guard reuses the SQL guard's rules for SQL on a command line. The permission deny list stays as a first line but is not the tested control; exact-string patterns cannot be tested against Claude Code's matcher from here. Any new "Blocked" promise in the README must land in a guard with a test, not only in the deny list.

## 2026-09-12: Heredoc bodies are data

The shell guard skips the body of a heredoc unless it is fed to a shell or a SQL client. A heredoc to `python3` or `node` is not inspected; the guard is a guard, not a sandbox, and the alternative blocks every documentation edit. Recorded in `SECURITY.md` as a known limit.

## 2026-09-12: Versions are dates, stamped on install

`VERSION` holds a date (`2026.09.12`). The installer writes it into `.claude/autopilot.json` in the target, and the session-start hook reports it. No semantic versioning: every merge to `main` is a release and the changelog date is the version. Tags are optional.

## 2026-09-11: The payload lives under `config/`, not at the root

The root is the installed copy; `config/` is the source. Extracting with a wildcard (`*/config/*`) means the install command survives a repo rename, which happened the same day.

## 2026-09-11: Repository settings are changed by hand

The cloud session's GitHub proxy allows git and pull request operations but refuses repository-settings writes: rename, description, topics, branch protection. A probe of the API returned 200 for a read, which was misleading. The owner does these in the GitHub UI; sessions should ask, not retry.

## 2026-09-11: Licence deferred

The repo is public with no licence file, which legally means all rights reserved. Deliberately left for the owner to choose (MIT or similar versus proprietary). Recorded so it is not mistaken for an oversight.
