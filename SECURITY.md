# Security

Beyond Autopilot exists to make AI-assisted work safe on live systems. If you find a way past its controls, we want to know.

## What counts

- A query that reaches a database tool despite being one the SQL guard is meant to block (DROP, TRUNCATE, ALTER, GRANT, REVOKE, RLS or role changes, DELETE or UPDATE without WHERE, writes to protected schemas).
- A permission pattern in `config/.claude/settings.json` that allows something the README's "Blocked" or "One tap" tiers say it should not.
- Anything in `install.sh` that could write outside the target directory or execute untrusted content.

## Reporting

Open a GitHub issue titled `Security:` with the exact input that got through and what you expected. For a database bypass, include the query as a fenced code block. If you would rather not post it publicly, email hello@gobeyond.co.nz with the same detail.

## What to expect

A confirmed bypass gets a test in `tests/sql-guard.test.js` that reproduces it, a fix, and a changelog line, in one pull request. The guard fails closed by design, so a fix will usually tighten rather than loosen.

## Scope notes

The guard sees only what Claude Code sends to a hook. It does not inspect SQL run through a shell (`psql`, `supabase db`), which is why those commands sit in the "ask" or "deny" tiers instead. Keeping the two in step is part of any change to either.
