# Beyond Autopilot: Claude Code working rules

These rules apply to every project. Project-specific detail (stack, database, commands) goes in a `## Project` section at the bottom.

## Autopilot
- Do not ask for confirmation on routine steps. Read, edit, run, query, test, commit and move on.
- Stop and ask only when: a permission prompt fires, a step touches real user data beyond what you created this session, a fix has failed twice, or you are about to spend money or change what users can see.
- When you ask, ask one question with a recommended answer. Never a list of questions.
- Finish the whole task, then give one short summary: what changed, what you verified, what you could not verify, anything I need to check.
- Never invent a fact: a phone number, address, price, spec, figure, date, credential or claim. Leave it empty, mark it TBC, and log it in `docs/open-questions.md`. An entry there is a licence to stop and ask rather than guess.
- Never close a business, legal, clinical, safety or financial question yourself. Draft, then ask.

## Databases (assume every database is live)
- Prefer a dev branch or local instance for anything experimental. Only touch production when the task needs it.
- SELECT freely. Before any DELETE or UPDATE, run a SELECT with the same WHERE and state the row count in your reply.
- DELETE and UPDATE always target explicit ids, never a broad column match. Wrap multi-statement writes in a transaction.
- Test data: tag it so it is obviously yours (name prefix `zz_test_`) and delete it by id when done.
- Never run DROP, TRUNCATE, ALTER, RLS or role changes, or write to auth/storage/system schemas via a query tool. A hook blocks these. Use a migration and ask.
- Schema changes go through the project's migration tool, reviewed by me, then applied. A migration applied through a connector or dashboard is not done until its SQL file is committed in the same change. Never edit a migration that has run.
- Row level security is written with the table, not later, and verified as `authenticated` or `anon` from a second tenant, never as `postgres` or the service role. A denied RLS write returns zero rows, not an error; count rows.
- The service role key never reaches a client bundle or a `NEXT_PUBLIC_`, `PUBLIC_` or `VITE_` variable.
- Before touching a connection string, auth, env vars, a migration or a deploy on a platform new to this repo, read the `beyond-traps` skill.

## Deploys and infrastructure
- Deploying, merging, pushing, creating or deleting cloud resources, and changing environment variables need my ok. These are set to ask.
- Never edit `.env`, secrets, `.github`, or `.claude` config. If a secret or variable is needed, tell me what and where. Report a secret as set or missing, never its value.
- Build-time variables (`NEXT_PUBLIC_*`, `PUBLIC_*`, `VITE_*`) need a rebuild, not a restart, and the app must fail closed when one is missing.
- After a deploy, wait for it, then confirm the effect, not the gesture: load the page, call the endpoint, read the log.
- The git author stays as configured. If a push is rejected (GH007) or a deploy skips an unmatched author, the fix is the account's GitHub noreply address, set by a human. Never change the author to force a push.

## Code
- Work on a feature branch. Commit after each working change with a short message. Pushing and merging need my ok.
- Run the test suite or a build before calling anything finished. Green typecheck and tests are necessary, not sufficient: verify against the real thing (run it, render the screen, call the endpoint) and say what was verified and what was not. "I could not test this" beats a confident silence.
- Before committing a new test as passing, make it fail: revert the fix or plant the bug, watch it go red, restore. A check that cannot fail is not a check.
- Never weaken, skip or relax a check or guard to get green. If a check blocks the work, either the work or the check is wrong; fix one and say which.
- A route, screen, job or flag with no caller or no entrance is not finished.
- When you write a rule, sweep the codebase for every other place it applies. A rule applied only where it was found is half a rule.
- Money is integer cents, never a float. GST is derived once at the total. The server prices every order.
- Match the existing style of the repo. Do not add dependencies without saying why.
- Commit messages say what changed, why, and what was verified, including what was not.
- Multi-session task: leave a NOTES.md at the repo root, dated, with where you got to, what is next, and what this environment could not see or verify.

## Workflow
- Anything bigger than a small change starts with `/plan`. The plan lives in `docs/plans/` and commits reference it.
- Before calling a task done, run `/review` and fix what it finds.
- When I correct you, or you catch a mistake of your own, run `/lesson` so it becomes a test, rule or hook rather than a memory.
- If a fix has failed twice, stop guessing and use the `systematic-debugging` skill before a third attempt. Before claiming anything is done, fixed or passing, the `verification-before-completion` skill applies.
- Decisions live in `docs/decisions` or `docs/adr`. Supersede one with a new entry; never work around it quietly.

## Style
- New Zealand English. No em dashes anywhere, including code comments and commit messages.
- Short replies. Lead with what you did, not what you are about to do.

## Project
- Name: Beyond Autopilot. This is the source repo for the payload, not a consumer of it, but it runs the payload too so every rule is felt here first.
- Run and test: `bash scripts/verify.sh` is the only entry point. It is what CI runs.
- Source of truth: `config/` is the payload. The root `.claude/`, the rules above this section, and the docs templates are the installed copy. Edit `config/`, then run `bash scripts/sync-root.sh`; `verify.sh` fails if the two drift.
- Every change to `config/` or `install.sh` gets a line in `CHANGELOG.md` saying where it came from, and bumps `VERSION` (date-based).
- Do not add a `## Project` section to `config/CLAUDE.md`. Downstream repos fill that in.
- Known environment limit: the cloud GitHub proxy refuses repository-settings writes (rename, topics, description, branch protection). Ask the owner to do those by hand. See `docs/decisions.md`.
- The payload denies the Edit tool on `.github/**` and `.claude/**`. That applies here too. Change CI with a shell heredoc, and change `.claude/` only through `config/` and the sync script.
