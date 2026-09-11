# Claude Code autopilot config and AI process audit

The single source for the Claude Code setup that goes into every project, plus the audit that tells us what to add to it next.

Two things live here:

1. **Autopilot config** (`config/`): a drop-in `.claude/` folder and `CLAUDE.md` so Claude Code runs routine work without prompts while still stopping for anything that can hurt a live system.
2. **AI process audit** (`config/.claude/commands/audit.md`, docs in `docs/audit/`): a `/audit` slash command that reviews the AI engineering process around a repo and produces a ranked list of the smallest changes that would make the AI materially better. Findings that apply to every project come back here as changes to the config.

Install once per repo, run `/audit` every 60 to 90 days, fold the findings back into `config/`. Each project makes the next one better.

## Layout

```
config/                               the installable payload, copied to the root of a target repo
  CLAUDE.md                           working rules, Project section filled in per repo
  .claude/settings.json               permissions (allow / ask / deny) and hooks
  .claude/hooks/sql-guard.js          PreToolUse hook that blocks dangerous SQL
  .claude/commands/audit.md           the /audit prompt
docs/
  INSTALL-CLOUD.md                    how to install into a cloud session, or locally
  audit/HOW-TO-RUN.md                 how to run the audit and act on it
  audit/OWNER-INTAKE.md               questionnaire to fill in before an audit
CHANGELOG.md                          what changed and which audit or project it came from
CLAUDE.md                             rules for editing this repo (not the payload)
```

The payload sits under `config/` rather than at the root on purpose. The payload's own deny rules stop Claude editing `.claude/settings.json` and hooks in a target repo. Keeping it one level down means sessions on this repo are free to edit it.

## Quick install (cloud session)

Paste as the first message in a cloud session on the target repo:

```
Install my standard Claude Code config into this repo:

1. Run:
   curl -L https://github.com/YeahBuddyNZ/autopilot-config-into-a-cloud/archive/refs/heads/main.tar.gz | tar xz --strip-components=2 -C . autopilot-config-into-a-cloud-main/config
2. If this repo already has a CLAUDE.md, keep its content and append it under the "## Project" heading of the new one.
3. Fill in the "## Project" section with what you can see: name, stack, how to run and test, migration tool.
4. Commit as "Add Claude Code autopilot config" and push to the current branch.
5. Tell me when it's pushed and which branch.
```

Then merge to the default branch and start a fresh session. Full detail, private-repo and local variants in `docs/INSTALL-CLOUD.md`.

## What each permission tier does

| Tier | Examples |
|---|---|
| Silent | reads, edits, SELECT/INSERT/UPDATE/DELETE via a query tool, npm/pnpm/yarn/bun run/test, local git commits, read-only cloud tools |
| One tap | deploys, migrations, git push/merge, branch create/delete/merge, env var changes, cloud resource create/delete, npx, curl, rm, ssh, docker, gh |
| Blocked | .env and key reads, force push, hard reset, git clean, db reset, sudo, chmod -R, editing .github or .claude |

## SQL guard

`sql-guard.js` runs before any MCP query tool (Supabase, Cloudflare D1, Render Postgres). It blocks DROP, TRUNCATE, ALTER, GRANT/REVOKE, RLS and role changes, writes to system schemas, DELETE or UPDATE without WHERE, DELETEs not targeting an id column, and WHERE true. Comments and string literals are stripped first so they cannot be used to hide a keyword. Fails closed. Needs Node, which Claude Code already requires.

Test it locally:

```
echo '{"tool_input":{"query":"delete from public.users"}}' | node config/.claude/hooks/sql-guard.js
```

Exit code 2 with a BLOCKED message means it is working.

## Connector names

claude.ai connectors appear as `mcp__claude_ai_<Server>__<tool>`. If a tool still prompts, run `/permissions` in a session to see the exact server name and adjust the prefix in `settings.json`.

## Running the audit

See `docs/audit/HOW-TO-RUN.md`. Short version: fill in `OWNER-INTAKE.md`, drop it in `docs/ai-process-audit/` in the target repo, run `/audit`, read the executive summary and the stop-doing list first.

## Adding to this repo

- Payload changes go under `config/`. Test `settings.json` still parses and the hook still blocks before pushing.
- Every change gets a line in `CHANGELOG.md` saying where it came from (which audit, which project, what went wrong).
- New Zealand English. No em dashes anywhere.
