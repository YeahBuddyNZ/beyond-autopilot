# OWNER-INTAKE.md

Copy this into `docs/ai-process-audit/OWNER-INTAKE.md` in the repo being audited and fill it in before running `/audit`. Short answers. "Don't know" is a valid answer and is itself useful to the audit.

## Project

- One-line description of what the system does:
- Who uses it and what data does it hold:
- Team size, and who reviews AI-generated code:
- Release cadence and deployment target:
- Regulatory or security exposure (payments, personal data, health, none):
- Expected lifespan (throwaway, months, years):
- Roughly what share of the codebase you personally understand well:

## Tooling

- Which AI tools you use and how (Claude Code, Cursor, Copilot, chat, other):
- Which model(s):
- Any hooks, permissions, MCP servers or subagents configured:

## How you actually work

- How does a task start? (issue, chat message, plan file, "just start coding"):
- Do you write acceptance criteria before the AI starts? Always / sometimes / never:
- Do you ask for a plan first? Always / sometimes / never:
- Where do plans end up afterwards? (repo, chat, nowhere):
- How do you decide the AI is finished? (tests, run it, read the diff, trust it):
- What does the AI run on its own vs what you run yourself:
- What do you always do manually because you do not trust the AI to:
- What do you approve before it happens (deploys, migrations, deletes, deps, nothing):

## Pain

- The last three times the AI got something badly wrong, what happened:
- The mistake it makes most often:
- What you find yourself correcting or re-explaining repeatedly:
- The slowest part of getting a feature from idea to merged:
- Anything you have tried to fix the process, and whether it worked:

## Knowledge

- The five most important rules or invariants of this system that are not written down anywhere:
- Decisions you regret or would make differently:
- Approaches you tried and rejected, and why:
- External integrations with quirks the AI keeps getting wrong:

## Last ten tasks

| # | Task (one line) | First pass OK? | Iterations | You had to step in? | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |
| 6 | | | | | |
| 7 | | | | | |
| 8 | | | | | |
| 9 | | | | | |
| 10 | | | | | |
