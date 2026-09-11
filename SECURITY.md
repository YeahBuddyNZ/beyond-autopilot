# Security

Beyond Autopilot exists to make AI-assisted work safe on live systems. If you find a way past its controls, we want to know.

## What the guards block

This is the one place the list lives. The tests in `tests/` are the authoritative version; if the two disagree, the tests win and this file is wrong.

**SQL guard** (`sql-guard.js`, on every MCP database query tool): DROP, TRUNCATE, ALTER, GRANT and REVOKE, role or user creation, RLS policy changes and toggles, SECURITY DEFINER, `WHERE true` or `1=1`, COPY and file or backend-control functions, role switches, any write to auth, storage, vault or system schemas, DELETE without WHERE, DELETE whose WHERE names no id column, UPDATE without WHERE, MERGE. Comments and string literals are stripped first so a keyword cannot hide in text.

**Shell guard** (`bash-guard.js`, on every shell command): `rm` with recursive and force in any spelling, `rm` on root, home or a wildcard, `git push` with any force flag or a `+` refspec, `git push` that deletes a remote branch, `git reset --hard`, `git clean`, force-deleting a branch, `git checkout -- .` and `git restore .`, history rewrites, `sudo` and friends, `chmod -R`, world-writable chmod, `chown -R`, `dd` and `mkfs`, `supabase db reset`, `prisma migrate reset`, `wrangler delete`, `vercel remove`, `dropdb`, reading or uploading `.env`, key, certificate, `.ssh` or `.aws` paths, dumping the whole environment, and any SQL on a command line (`psql -c`, `supabase db query`, a heredoc into a SQL client) that the SQL guard would block. Wrappers are peeled first: `xargs`, `timeout`, `nohup`, `npx`, `pnpm dlx`, environment assignments, `$(...)` and backticks.

## What counts as a report

- A command or query that gets through despite being on the list above.
- A permission pattern in `config/.claude/settings.json` that allows something the README's "Blocked" or "One tap" tiers say it should not.
- Anything in `install.sh` that could write outside the target directory or execute untrusted content.

## Reporting

Open a GitHub issue titled `Security:` with the exact input that got through and what you expected. For a database bypass, include the query as a fenced code block. If you would rather not post it publicly, email hello@gobeyond.co.nz with the same detail.

## What to expect

A confirmed bypass gets a test in `tests/sql-guard.test.js` that reproduces it, a fix, and a changelog line, in one pull request. The guard fails closed by design, so a fix will usually tighten rather than loosen.

## Known limits

The guards see only what Claude Code sends to a hook, and they are guards, not a sandbox. Known gaps, by design: a heredoc fed to `python3`, `node` or another interpreter is not inspected (only heredocs to a shell or SQL client are); a script file that itself runs a destructive command is not inspected when the script is invoked; commands inside `eval` strings are checked only as far as the tokeniser can see. The permission tiers in `settings.json` are the other line of defence and are kept in step with the guards.
