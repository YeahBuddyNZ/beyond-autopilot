# Installing the autopilot config into a cloud session

Cloud sessions start from a clone of your GitHub repo and have no file drop, so the config has to come from somewhere the session can reach. This repo is that somewhere. GitHub is on the default network allowlist, so every cloud session can pull it.

The installable payload lives under `config/` in this repo:

```
config/.claude/settings.json          permissions and hooks
config/.claude/hooks/sql-guard.js     blocks dangerous SQL before it runs
config/.claude/commands/audit.md      the /audit slash command
config/CLAUDE.md                      working rules, with a Project section to fill in
```

Everything under `config/` is copied to the root of the target repo, so `config/.claude` becomes `.claude` and `config/CLAUDE.md` becomes `CLAUDE.md`.

## Installing into any repo from a cloud session

Start a cloud session on the target repo and paste this as your first message:

```
Install my standard Claude Code config into this repo:

1. Run:
   curl -L https://github.com/YeahBuddyNZ/autopilot-config-into-a-cloud/archive/refs/heads/main.tar.gz | tar xz --strip-components=2 -C . autopilot-config-into-a-cloud-main/config
2. If this repo already has a CLAUDE.md, keep its content and append it under the "## Project" heading of the new one.
3. Fill in the "## Project" section with what you can see: name, stack, how to run and test, migration tool.
4. Commit as "Add Claude Code autopilot config" and push to the current branch.
5. Tell me when it's pushed and which branch.
```

The session will prompt you a few times during this (curl, the commit, the push). Allow them. That is the last time you should see routine prompts on this repo.

## Activate it

The config only loads when a session clones it, so:

1. Merge that branch to main (or whatever the repo's default branch is). Cloud sessions clone the default branch unless you name another one.
2. Start a fresh cloud session on the repo.
3. Sanity check: ask it to run `delete from public.some_table` with no WHERE against a database tool. It should come back blocked by the guard, not ask you to allow it.
4. Type `/audit` and it should offer to run the process audit. See `docs/audit/HOW-TO-RUN.md`.

## If this repo is ever made private

curl will 404. Use this first message instead:

```
Use the GitHub connector to read every file under config/ in YeahBuddyNZ/autopilot-config-into-a-cloud on main and write them into this repo at the same paths with the config/ prefix removed:
- config/.claude/settings.json        -> .claude/settings.json
- config/.claude/hooks/sql-guard.js   -> .claude/hooks/sql-guard.js
- config/.claude/commands/audit.md    -> .claude/commands/audit.md
- config/CLAUDE.md                    -> CLAUDE.md
Then follow steps 2 to 5 from my standard install: merge any existing CLAUDE.md into the Project section, fill in the Project section, commit as "Add Claude Code autopilot config", push, and report the branch.
```

## Updating later

Edit the files under `config/` in this repo, push, then run the install message again in each repo. The tar command overwrites the files, so it is safe to re-run. The `## Project` section of the target repo's CLAUDE.md will be overwritten too, so ask the session to keep it (step 2 of the install message covers this).

## Local install

For a repo on your own machine:

```
git clone https://github.com/YeahBuddyNZ/autopilot-config-into-a-cloud.git /tmp/autopilot
cp -r /tmp/autopilot/config/.claude /tmp/autopilot/config/CLAUDE.md /path/to/your/repo/
```

To apply it to every project on the machine, copy the `permissions` and `hooks` blocks from `settings.json` into `~/.claude/settings.json`, copy `sql-guard.js` to `~/.claude/hooks/`, and change the hook command to `node ~/.claude/hooks/sql-guard.js`. Cloud sessions do not read `~/.claude`, so repos you use in the cloud still need the repo copy.

## No GitHub at all (fallback)

Paste each file's contents as a fenced code block into the session and ask it to write them to the paths above, then commit and push. Works but is fiddly on a phone for the settings.json.
