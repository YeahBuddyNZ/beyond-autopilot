# The AI process audit

`/audit` reviews the **process** around a codebase, not the product. Code quality is treated as evidence about the process. The one question it answers:

> How effective is the AI engineering system around this codebase, where does it fail, and what is the smallest set of changes that would make the AI materially better at designing, implementing, testing and maintaining it?

It ships with the config as `.claude/commands/audit.md`, so any repo with Beyond Autopilot installed can run it.

## What you get

Everything lands under `docs/ai-process-audit/` in the repo being audited. Nothing else in the repo is modified.

| File | What it is |
|---|---|
| `AI-PROCESS-AUDIT.md` | The report. One-page executive summary first: maturity score, three most important findings, three most important changes, the biggest bottleneck, and what to do on Monday |
| `QUESTIONS-FOR-OWNER.md` | Everything the audit could not see and needs you to answer |
| `audit-scorecard.yaml` | Machine-readable scores so the next audit can measure movement |
| `drafts/` | Proposed artefacts, clearly labelled, not applied: a restructured `CLAUDE.md`, a knowledge tree, ADR and plan templates with worked examples, a golden task suite, an evaluation log template, verification gate config, and a one-page "when the AI gets it wrong" runbook |
| `00-` to `04-` phase files | The working: inventory, current process, diagnosis through eight lenses, failure forensics, recommendations |

Every finding cites evidence. Every recommendation traces to a finding. Every top-ten change has a metric, a baseline and a target.

## Setup (5 minutes)

1. Install Beyond Autopilot into the repo if it is not there already (see `INSTALL.md`).
2. Copy `OWNER-INTAKE.md` from this repo into the target repo as `docs/ai-process-audit/OWNER-INTAKE.md` and fill it in. Short answers. "Don't know" is a valid answer and is itself useful.
3. If you have them, also drop in: session transcripts or exports, CI logs from the last month, an export of your issue tracker or task list.
4. Run `/audit`.

## Modes

| Command | When |
|---|---|
| `/audit` | First audit of a real project. Full run |
| `/audit quick` | Small repo, side project, or a first look. Under an hour of agent time |
| `/audit re-audit` | A previous `audit-scorecard.yaml` exists. Adds a delta section showing what moved |
| `/audit portfolio` | Several repos built the same way. Quick on each, then a cross-repo section |

Full mode on a real repo is a long run. Let it finish; it checkpoints each phase to disk.

If the repo does not have the config installed, paste the contents of `config/.claude/commands/audit.md` into a fresh session with the repo open instead.

## Acting on it (the part that matters)

- Read the executive summary and the stop-doing list first. Delete before you add.
- Adopt the "Do immediately" items this week. Do not start "Do next" until those are in.
- Put the draft `CLAUDE.md` in place only after you have read it line by line. It is a proposal.
- Start the eval log on the next task you give the AI. Ten rows is enough to see a trend.
- Run the golden task suite once now to get a baseline, before changing anything else.
- Re-audit in 60 to 90 days. The scorecard YAML makes the comparison automatic.

## Across several repos

Install the config in each, run `/audit portfolio` from the one you consider the reference. The cross-repo section names the instructions and commands that should become a shared base. That shared base belongs in this repo, under `config/`, so every new project starts with it.

## Feeding findings back into Beyond Autopilot

The reason the audit lives here is that each run improves the base config. After an audit:

| The audit says | It goes in |
|---|---|
| A rule every project needs | `config/CLAUDE.md` |
| A check that should be enforced, not remembered | `config/.claude/settings.json` (permission) or a new hook under `config/.claude/hooks/` |
| A procedure that should be repeatable | A new command under `config/.claude/commands/` |
| The audit itself missed something | `config/.claude/commands/audit.md` |

Record each change in `CHANGELOG.md` with the repo and audit date it came from. See `CONTRIBUTING.md`.
