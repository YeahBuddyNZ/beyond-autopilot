---
description: Independent review pass over a change before it is called done. Optional argument names a branch, commit range or pull request; blank reviews the current work against the default branch.
argument-hint: [branch|range|PR]
---

Review target: $ARGUMENTS (blank means the working tree plus unpushed commits, compared with the default branch).

Review this as someone who did not write it. List first, fix after.

1. Acceptance: find the plan in `docs/plans/` or the task as given. Quote each acceptance criterion and mark it met or not met, with the evidence.
2. Correctness: inputs that break it, error handling, empty and null cases, off-by-one, concurrency, time zones.
3. Tests: do the new tests assert behaviour, or only pass? Would they fail if the change were reverted? Run the suite and say what ran.
4. Data safety: any query, migration or write against real data; any deletion; anything that cannot be undone.
5. Security: secrets in code or logs, injection, auth boundaries, new dependencies and why they are needed.
6. Architecture: does it respect the module boundaries and conventions already in this repo? Anything that works but violates the structure.
7. Scope: anything changed that the task did not ask for.

Output, in this order:

- Findings ranked by severity, each with `file:line` and a one-line fix.
- Verdict: ship / fix first / needs a human.
- Then fix every "fix first" item, re-run the tests, and give a two-line summary of what changed.
- Finally append one row to `docs/ai-process-audit/eval-log.md` for the task this change belongs to: date, task, model, payload version (from `.claude/autopilot.json`), whether the first attempt met the criteria, iterations, human interventions, tests that failed along the way, minutes, one-line note. Create the file with its header if it is missing.
