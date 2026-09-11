# AI Process Audit: How to run it

The audit prompt ships with the autopilot config as the `/audit` slash command (`config/.claude/commands/audit.md`). Any repo that has the config installed can run it. It audits the **process** around the codebase, not the product, and its output is meant to be acted on the following Monday.

## Setup (5 minutes)

1. Install the autopilot config into the repo if it is not there already. See `docs/INSTALL-CLOUD.md`.
2. Create `docs/ai-process-audit/` in the target repo and drop in a filled-in copy of `OWNER-INTAKE.md` (template in this folder).
3. If you have them, also drop in: session transcripts or exports, CI logs from the last month, an export of your issue tracker or task list.
4. Run `/audit`. Add `quick`, `re-audit` or `portfolio` after it if you want something other than Full, for example `/audit quick`.

If the repo does not have the config installed, paste the contents of `config/.claude/commands/audit.md` into a fresh session with the repo open instead.

Full mode on a real repo is a long run. Let it finish; it checkpoints each phase to disk.

## Acting on it (the part that matters)

- Read the executive summary and the stop-doing list first. Delete before you add.
- Adopt the "Do immediately" items this week. Do not start "Do next" until those are in.
- Put the draft `CLAUDE.md` / `AGENTS.md` in place only after you have read it line by line. It is a proposal.
- Start the eval log on the next task you give the AI. Ten rows is enough to see a trend.
- Run the golden task suite once now to get a baseline, before changing anything else.
- Re-audit in 60 to 90 days. The scorecard YAML makes the comparison automatic.

## Running across several repos

Install the config in each repo, run `/audit portfolio` from the one you consider the reference. Expect the cross-repo section to tell you which instructions and Skills should become a shared base. That shared base belongs in this repo, under `config/`, so every new project starts with it.

## Feeding findings back into this repo

The point of keeping the audit here is that each run makes the base config better. After an audit:

- A rule the audit says every project needs goes into `config/CLAUDE.md`.
- A permission or hook the audit says should be enforced goes into `config/.claude/settings.json` or a new hook under `config/.claude/hooks/`.
- A procedure the audit says should be a Skill or command goes under `config/.claude/commands/`.
- Anything that changes the audit itself goes into `config/.claude/commands/audit.md`.
- Note the change in `CHANGELOG.md` with the repo and audit date it came from.
