# Owner intake (partial, filled from session evidence)

Filled in by the auditing session from what it could observe. Anything marked "Not visible" is for the owner.

## Project

- One-line description: the source repo for Beyond Autopilot, a Claude Code config payload plus an AI process audit, installed into other projects.
- Who uses it and what data does it hold: Beyond and anyone who runs the installer. Holds no user data. Public repo.
- Team size, and who reviews AI-generated code: one owner. Reviews happen at the pull request. Depth of review: Not visible.
- Release cadence and deployment target: every merge to `main` is live for every install. No tags.
- Regulatory or security exposure: none directly, but the payload governs what an AI may do against live databases and infrastructure in every downstream repo, so a defect here has wide reach.
- Expected lifespan: years. Stated intent is "the basis of every good project".
- Share of the codebase the owner understands well: Not visible.

## Tooling

- AI tools: Claude Code cloud sessions (evidence: this repo was built entirely in them).
- Model: Not visible.
- Hooks, permissions, MCP servers: none active on this repo itself. The payload under `config/` is not installed at the root.

## How you actually work

- How a task starts: chat message with attachments, one line of intent (evidence: session transcript).
- Acceptance criteria before the AI starts: never, so far.
- Plan first: never on this repo. `docs/plans/` is absent.
- Where plans end up: chat.
- How you decide the AI is finished: Not visible. The AI's own summary and CI are what is available.
- What the AI runs on its own vs what you run: the AI runs everything; the owner merges.
- What you approve before it happens: merge. Repo rename was done by the owner by hand after the AI could not.

## Pain

- Last three times the AI got something badly wrong: see failure instances F-01 to F-05 in the report. All within one session, all caught before merge, one only because a verification script was written mid-task.
- Everything else: Not visible.

## Knowledge

- Rules not written down: the payload must stay under `config/` (written down, in `CLAUDE.md`). The GitHub proxy in cloud sessions refuses repository-settings writes (not written down anywhere).
- Decisions you regret: Not visible.
- Approaches rejected: payload at repo root (rejected, reason recorded in README); cloning the repo a second time after rename (rejected in chat, not recorded).

## Last ten tasks

| # | Task (one line) | First pass OK? | Iterations | You had to step in? | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | Push two zips into git, merge audit into repo | yes | 1 | no | PR #1 |
| 2 | Merge PR #1 | yes | 1 | no | |
| 3 | Rebrand, full docs, installer, CI, tests, commands | no | 4 | no | Installer bug, test runner bug, verify bug, em dash bug, all caught pre-push |
| 4 | Rename the GitHub repo | no | 1 | yes | Proxy refused; owner renamed by hand |
| 5 | Repoint docs at renamed repo | yes | 1 | no | |
| 6 | Run the audit on this repo | in progress | | | |
