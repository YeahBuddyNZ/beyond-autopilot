# Installing Beyond Autopilot

There are three places the config can live. Pick the one that matches how you work. All three can be combined.

| Where | Who it applies to | Cloud sessions see it? |
|---|---|---|
| In the repo (`.claude/` and `CLAUDE.md` committed) | Everyone who clones that repo | Yes |
| On your machine (`~/.claude/`) | Every repo you open locally | No |
| Pasted by hand | One repo, no script | Yes, once committed |

Repo install is the recommended default. It is the only one cloud sessions pick up.

## 1. Repo install from a cloud session

Cloud sessions start from a clone of your GitHub repo and have no file drop, so the config comes from this repo over the network. GitHub is on the default allowlist.

Start a cloud session on the target repo and paste this as your first message:

```
Install Beyond Autopilot into this repo:

1. Run:
   curl -sL https://raw.githubusercontent.com/YeahBuddyNZ/beyond-autopilot/main/install.sh | bash
2. Fill in the "## Project" section at the bottom of CLAUDE.md with what you can see: name, stack, how to run and test, migration tool.
3. Commit as "Add Beyond Autopilot config" and push to the current branch.
4. Tell me when it's pushed and which branch.
```

The session will prompt you a few times during this (the curl, the commit, the push). Allow them. That is the last time you should see routine prompts on this repo.

### Activate it

The config only loads when a session clones it, so:

1. Merge that branch to the default branch. Cloud sessions clone the default branch unless you name another.
2. Start a fresh cloud session on the repo.
3. Run the checks in the README under "Check it's working".

## 2. Repo install from your own machine

Inside the repo:

```
curl -sL https://raw.githubusercontent.com/YeahBuddyNZ/beyond-autopilot/main/install.sh | bash
```

Or into a specific directory:

```
curl -sL https://raw.githubusercontent.com/YeahBuddyNZ/beyond-autopilot/main/install.sh | bash -s -- /path/to/repo
```

Commit `.claude/` and `CLAUDE.md`, fill in the Project section, push. Local sessions pick it up on next launch.

## 3. Whole machine install

To apply the permissions and SQL guard to every repo you open locally, without committing anything:

```
git clone https://github.com/YeahBuddyNZ/beyond-autopilot.git /tmp/beyond-autopilot
mkdir -p ~/.claude/hooks
cp /tmp/beyond-autopilot/config/.claude/hooks/sql-guard.js ~/.claude/hooks/
```

Then copy the `permissions` and `hooks` blocks from `config/.claude/settings.json` into `~/.claude/settings.json`, and change the hook command to:

```
node ~/.claude/hooks/sql-guard.js
```

Cloud sessions do not read `~/.claude`, so repos you use in the cloud still need the repo install.

## What the installer does

`install.sh` is deliberately boring. In order:

1. Checks `curl`, `tar` and `node` are available.
2. Downloads the archive of this repo and extracts only the `config/` payload into a temp directory. The extraction uses a wildcard, so it keeps working if this repo is ever renamed.
3. If the target already has `.claude/settings.json` and it differs, keeps a copy as `.claude/settings.json.bak`.
4. Handles an existing `CLAUDE.md` without losing anything. If it is not ours, its content is appended under the Project section of the new one, clearly marked. If it is ours from an earlier install, the rules above `## Project` are refreshed from the payload and everything from `## Project` to the end is kept exactly as you had it.
5. Copies `.claude/` and `CLAUDE.md` in. Other files under `.claude/` are left alone.
6. Creates the docs templates (`docs/plans/README.md`, `docs/ai-process-audit/eval-log.md`, `docs/ai-process-audit/lessons.md`) only if they do not exist. Once they exist they are yours; the installer never touches them again.
7. Writes `.claude/autopilot.json` with the payload version, source and time. The session-start check reads it.
8. Verifies the installed `settings.json` parses and that both guards block what they should. Fails loudly if any check fails, and prints what it installed.

It is safe to re-run. Re-running refreshes `.claude/` and the rules part of `CLAUDE.md`, keeps your Project section and your logs, and repeats steps 3 to 8.

Three environment variables change where it pulls from:

```
AUTOPILOT_REPO=owner/repo        # default YeahBuddyNZ/beyond-autopilot
AUTOPILOT_REF=ref                # branch, tag or commit; default main. Pin a project with a release tag, e.g. v2026.09.12
AUTOPILOT_ARCHIVE=/path/to.tar.gz  # install from a local archive instead of downloading
AUTOPILOT_SOURCE=label             # what .claude/autopilot.json records as the source (optional)
```

## Without the installer

If `raw.githubusercontent.com` is blocked for you, the archive route works with the same result:

```
curl -L https://github.com/YeahBuddyNZ/beyond-autopilot/archive/refs/heads/main.tar.gz | tar xz --strip-components=2 -C . --wildcards '*/config/*'
```

This does not merge an existing `CLAUDE.md`, so if you have one, keep its content and paste it under the Project section yourself.

## If this repo is ever made private

Both curl routes will 404. From a cloud session, use the GitHub connector instead:

```
Use the GitHub connector to read every file under config/ in YeahBuddyNZ/beyond-autopilot on main and write them into this repo at the same paths with the config/ prefix removed:
- config/.claude/settings.json        -> .claude/settings.json
- config/.claude/hooks/sql-guard.js   -> .claude/hooks/sql-guard.js
- config/.claude/commands/audit.md    -> .claude/commands/audit.md
- config/CLAUDE.md                    -> CLAUDE.md
Keep any existing CLAUDE.md content under the Project section, fill in the Project section, commit as "Add Beyond Autopilot config", push, and report the branch.
```

## No GitHub access at all

Paste each file's contents as a fenced code block into the session and ask it to write them to the paths above, then commit and push. Works but is fiddly on a phone for `settings.json`.

## Updating an installed repo

Edit under `config/` in this repo and push. Then re-run the installer in each repo (or paste the cloud install message again). The Project section of the target's `CLAUDE.md` is preserved by the merge step, but read the result before committing.
