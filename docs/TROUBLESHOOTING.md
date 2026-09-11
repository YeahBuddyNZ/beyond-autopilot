# Troubleshooting

## It still prompts for something that should be silent

**A cloud session is not seeing the config.** The config loads when the session clones the repo. Check `.claude/settings.json` and `CLAUDE.md` are on the branch the session cloned (the default branch unless you named one), then start a fresh session.

**The connector name does not match.** claude.ai connectors appear as `mcp__claude_ai_<Server>__<tool>`, local MCP servers as `mcp__<server>__<tool>`. Run `/permissions` in a session to see the exact name of the tool that prompted, then add or adjust the prefix in `settings.json`. Both spellings are already there for the supported platforms.

**The command is not in the allow list.** Only the listed commands are silent. Anything else falls back to asking. If a command should be routine, add a `Bash(...)` pattern to `allow` in `config/.claude/settings.json` here and reinstall.

## It ran something it should have asked about

Check whether the tool name or command matches an `allow` pattern more broadly than intended. Wildcards are literal: `mcp__supabase__*` allows every Supabase tool that is not also listed under `ask`. `ask` and `deny` win over `allow`, so the fix is usually to add the specific tool to `ask`.

## The SQL guard blocked something legitimate

The guard is deliberately strict. Common cases:

| Blocked as | Why | What to do |
|---|---|---|
| DELETE must target an id column | The WHERE clause does not mention a column ending in `id` | Select the ids first, then delete by id |
| UPDATE without WHERE | A bulk update | Add a WHERE, or run it as a migration |
| ALTER statement | Schema change through a query tool | Use the project's migration tool |
| WHERE true | `where true` or `where 1=1` | Write the real condition |
| MERGE (review manually) | MERGE is hard to check safely | Run it yourself, or split into checked statements |

The guard fails closed, so an empty query or one it cannot parse is also blocked. It never modifies the query; it only allows or blocks.

To test it by hand:

```
echo '{"tool_input":{"query":"delete from public.users"}}' | node .claude/hooks/sql-guard.js
```

Exit code 2 with a `sql-guard BLOCKED` message means it is working. Exit 0 means the query would be allowed.

## The guard is not firing at all

- Node must be on PATH for the session. Claude Code already requires it, but check with `node --version`.
- The hook matcher covers tools whose name contains `execute_sql`, `query`, `d1_database_query` or `query_render_postgres`. A database tool with a different name needs adding to the `matcher` in `settings.json`.
- The hook command uses `$CLAUDE_PROJECT_DIR`, which Claude Code sets. If you moved `sql-guard.js` to `~/.claude/hooks/`, the command must be `node ~/.claude/hooks/sql-guard.js`.

## `/audit` is not recognised

The command file must be at `.claude/commands/audit.md` on the branch the session cloned. Re-run the installer, commit, merge, and start a fresh session.

## The installer failed

| Message | Cause | Fix |
|---|---|---|
| `curl is required` (or tar, node) | Tool missing from PATH | Install it, or use the paste fallback in `INSTALL.md` |
| `could not download` | No network route to GitHub, or the repo is private | Check the URL in a browser; use the GitHub connector route in `INSTALL.md` |
| `archive did not contain a config/ directory` | Wrong `AUTOPILOT_REPO` or `AUTOPILOT_REF` | Check the values, or leave them unset |
| `SQL guard did not block a bare DELETE` | Node is present but the hook did not run correctly | Run the manual test above and report the output in an issue |

## Existing `CLAUDE.md` content went missing

It did not. The installer appends any existing `CLAUDE.md` under the Project section with a heading that says it was merged. Scroll to the bottom. If you re-ran the installer after tidying, the tidy version is what was kept, because the installer only merges files it does not recognise as its own.

## I want to change the rules for one repo only

Edit that repo's `CLAUDE.md` Project section and `.claude/settings.json` directly. The next reinstall will keep the Project section but overwrite `settings.json` (with a `.bak` copy). If a change is good enough for one repo it is probably good enough for all of them, so consider sending it here instead.
