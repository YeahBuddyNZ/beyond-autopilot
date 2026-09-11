# Beyond Autopilot: Claude Code working rules

These rules apply to every project. Project-specific detail (stack, database, commands) goes in a `## Project` section at the bottom.

## Autopilot
- Do not ask for confirmation on routine steps. Read, edit, run, query, test, commit and move on.
- Stop and ask only when: a permission prompt fires, a step touches real user data beyond what you created this session, a fix has failed twice, or you are about to spend money or change what users can see.
- When you ask, ask one question with a recommended answer. Never a list of questions.
- Finish the whole task, then give one short summary: what changed, what you verified, anything I need to check.

## Databases (assume every database is live)
- Prefer a dev branch or local instance for anything experimental. Only touch production when the task needs it.
- SELECT freely. Before any DELETE or UPDATE, run a SELECT with the same WHERE and state the row count in your reply.
- DELETE and UPDATE always target explicit ids, never a broad column match. Wrap multi-statement writes in a transaction.
- Test data: tag it so it is obviously yours (name prefix `zz_test_`) and delete it by id when done.
- Never run DROP, TRUNCATE, ALTER, RLS or role changes, or write to auth/storage/system schemas via a query tool. A hook blocks these. Use a migration and ask.
- Schema changes go through the project's migration tool, reviewed by me, then applied.

## Deploys and infrastructure
- Deploying, merging, pushing, creating or deleting cloud resources, and changing environment variables need my ok. These are set to ask.
- Never edit `.env`, secrets, `.github`, or `.claude` config. If a secret or variable is needed, tell me what and where.

## Code
- Work on a feature branch. Commit after each working change with a short message. Pushing and merging need my ok.
- Run the test suite or a build before calling anything finished.
- Match the existing style of the repo. Do not add dependencies without saying why.
- Multi-session task: leave a NOTES.md at the repo root with where you got to and what is next.

## Workflow
- Anything bigger than a small change starts with `/plan`. The plan lives in `docs/plans/` and commits reference it.
- Before calling a task done, run `/review` and fix what it finds.
- When I correct you, or you catch a mistake of your own, run `/lesson` so it becomes a test, rule or hook rather than a memory.

## Style
- New Zealand English. No em dashes anywhere, including code comments and commit messages.
- Short replies. Lead with what you did, not what you are about to do.

## Project
<!-- Fill in per repo. Example:
- Name: Muster
- Stack: Next.js, Supabase (project id xxxx), Vercel
- Run: npm run dev / npm test / npm run build
- Migrations: supabase migration new <name>
- Notes: parents fill details via a link, medical fields are coach-only
-->
