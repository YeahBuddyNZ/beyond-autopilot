# Golden task suite for Beyond Autopilot

Six repeatable tasks with objective success criteria. Run the suite before and after any change to `config/CLAUDE.md`, the commands, or the guard, and log the result in the eval log. Starting state for all: `main` at the current head, fresh session.

```
id:            GT-01
title:         Block a new SQL class
task prompt:   "The SQL guard should also block `refresh materialized view`. Add it, with tests."
success criteria:
  - a new blocked case in tests/sql-guard.test.js that fails before the change and passes after
  - existing 26 cases still pass
  - CHANGELOG.md has a line for it
  - no em dashes
verification:  bash scripts/verify.sh
timebox:       15 minutes
```

```
id:            GT-02
title:         Add a platform
task prompt:   "Add Fly.io MCP tools to the permissions: read-only tools silent, deploys and secrets one tap."
success criteria:
  - both mcp__claude_ai_Fly__* and mcp__fly__* spellings present
  - deploy and secret tools appear in ask, not allow
  - settings.json still parses; no pattern appears in more than one list
  - README "Supported platforms" and CHANGELOG updated
verification:  bash scripts/verify.sh && grep -c fly config/.claude/settings.json
timebox:       15 minutes
```

```
id:            GT-03
title:         Add a command
task prompt:   "Add a /handover command that writes NOTES.md for the next session: where you got to, what is next, open questions."
success criteria:
  - config/.claude/commands/handover.md with frontmatter and description
  - installer output lists it (verify.sh checks every command installs)
  - docs/USAGE.md and README layout updated
verification:  bash scripts/verify.sh
timebox:       20 minutes
```

```
id:            GT-04
title:         Change installer behaviour safely
task prompt:   "The installer should refuse to run if the target is not a git repository, unless --force is passed."
success criteria:
  - install.sh exits non-zero with a clear message on a non-git directory
  - verify.sh gains a case for it and still passes end to end
  - docs/INSTALL.md documents the flag
verification:  bash scripts/verify.sh
timebox:       20 minutes
```

```
id:            GT-05
title:         Fix a reported bypass
task prompt:   "Someone reports that `DELETE FROM public.users WHERE user_id = 5 OR 1=1` gets through the guard. Confirm, fix, test."
success criteria:
  - a failing test reproduces the report before the fix
  - the fix blocks it without blocking `delete from public.users where id = 5`
  - SECURITY.md process followed: test, fix, changelog in one PR
verification:  bash scripts/verify.sh
timebox:       20 minutes
```

```
id:            GT-06
title:         Behaviour change with docs in step
task prompt:   "Rename the merged-notes heading the installer writes to '### Notes carried over from your previous CLAUDE.md'."
success criteria:
  - install.sh, scripts/verify.sh assertion, docs/INSTALL.md and docs/TROUBLESHOOTING.md all use the new wording
  - no stale reference to the old heading anywhere: grep returns nothing
verification:  bash scripts/verify.sh && ! grep -rn "Existing project notes" --exclude-dir=.git --exclude-dir=docs/ai-process-audit .
timebox:       10 minutes
```

Log each run: `date | GT id | model | payload commit | first pass y/n | iterations | interventions | minutes | notes`.
