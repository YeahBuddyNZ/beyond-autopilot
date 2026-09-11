# Working with Beyond Autopilot

This is what to expect once the config is installed, and how to get the most from it.

## The working model

**You give whole tasks. It finishes them.** The rules in `CLAUDE.md` tell it not to ask for confirmation on routine steps. It reads, edits, runs, queries, tests and commits, then gives you one short summary: what changed, what it verified, anything you need to check.

**It stops for four things only:**

1. A permission prompt fires (the "one tap" tier).
2. A step touches real user data beyond what it created this session.
3. A fix has failed twice.
4. It is about to spend money or change what users can see.

When it stops, it asks one question with a recommended answer. Never a list.

**It never touches secrets or its own config.** If it needs an environment variable, it tells you what and where. `.env`, keys, `.github` and `.claude` are read-blocked or edit-blocked in the permissions.

## Databases

Every database is treated as live. The rules and the SQL guard together mean:

- SELECT is free.
- Before a DELETE or UPDATE it runs a SELECT with the same WHERE and tells you the row count.
- DELETE and UPDATE target explicit ids. A DELETE without WHERE, or with a WHERE that does not mention an id column, is blocked by the hook before it reaches the database.
- DROP, TRUNCATE, ALTER, GRANT, REVOKE, RLS and role changes, and writes to auth, storage or system schemas are blocked. Schema changes go through your migration tool and you review them.
- Test data it creates is prefixed `zz_test_` and deleted by id when done.

The guard strips comments and string literals before checking, so a keyword hidden inside a string cannot slip past. It fails closed: anything it cannot parse is blocked. The same rules apply to SQL typed on a shell command line.

## The shell

A second guard reads every shell command before it runs. Recursive force deletes, force pushes, hard resets, `git clean`, privilege escalation, world-writable permissions, database resets, and reading or uploading secret files are blocked however the flags are spelled, and however the command is wrapped (`xargs`, `timeout`, `npx`, `$(...)`). The full list is in `SECURITY.md`. Writing files with heredocs is fine; the guard treats heredoc bodies as data unless they are piped into a shell or a SQL client.

## Session start

Every session begins with a one-line report from the session check: which payload version this repo runs, and a warning if the Project section is unfilled or a guard is missing. If you see a warning, fix it before giving the AI a task; an unfilled Project section is the most common reason for a session that guesses.

## Deploys and infrastructure

Deploying, merging, pushing, creating or deleting cloud resources, and changing environment variables all sit in the "one tap" tier. It will get everything ready and ask once. Approve, and it carries on.

## Code

- Works on a feature branch, commits after each working change.
- Runs the test suite or a build before calling anything finished.
- Matches the existing style of the repo and will not add a dependency without saying why.
- On a task that spans sessions, leaves a `NOTES.md` at the repo root with where it got to and what is next.

## The four commands

**`/plan <task>`** before anything bigger than a small change. It restates the task, inspects the affected code, writes numbered acceptance criteria, ordered steps with a verification command each, risks and out-of-scope, and saves it under `docs/plans/`. Commits reference the plan. If the task is small enough that the plan would be longer than the change, it says so and skips ahead.

**`/review`** before a task is called done. A fixed checklist run as if by someone else: acceptance criteria met or not with evidence, correctness, whether the tests would fail on a revert, data safety, security, architecture, scope creep. Findings ranked with `file:line`, a verdict, then the "fix first" items fixed.

**`/lesson <what went wrong>`** whenever you correct it, or it catches itself. It classifies the root cause, picks the matching control (test, rule, hook, doc, or a proposed permission change), implements it, proves it catches the original mistake, and logs a row in `docs/ai-process-audit/lessons.md`. The point is that you only correct any given thing once.

**`/audit`** every 60 to 90 days. See `AUDIT.md`.

The working rules in `CLAUDE.md` tell it to use the first three without being asked. You can still type them yourself.

## Getting good results

**Fill in the Project section.** The bottom of `CLAUDE.md` has a `## Project` block for the name, stack, run and test commands, and migration tool. Five lines there save an hour of the AI guessing.

**Write acceptance criteria.** "Add a filter to the orders endpoint, tested, existing tests green" beats "improve the orders page". The audit will tell you this too.

**Keep tasks to something one session can finish.** Large commits and fix chains are the audit's top signal of tasks that were too big.

**Let it commit.** Local commits are silent on purpose. Small commits make review easy and give the audit a clear history to read.

**Run the audit before you tune anything.** If you find yourself correcting the same thing twice, that is a finding. Run `/audit` and let it tell you whether the fix is a rule, a hook, a test or a command. See `AUDIT.md`.

## Style

New Zealand English throughout, including code comments and commit messages. No em dashes anywhere. Short replies that lead with what was done.
