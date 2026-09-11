---
description: Turn a correction or mistake into a durable control (a test, rule, hook or doc) so it cannot happen again. Argument is what went wrong, in one line.
argument-hint: [what went wrong]
---

What went wrong: $ARGUMENTS

A correction that lives only in this conversation is gone at session end. Convert it into something the next session cannot skip.

1. Classify the root cause. Pick one: model capability; missing context; poor instruction; missing tool; bad task decomposition; ambiguous requirement; missing validation; missing architectural constraint; missing feedback loop; excessive autonomy; insufficient autonomy.
2. Pick the matching control. Prefer enforcement over instruction.
   - Missing validation: a test, lint rule, type, or hook.
   - Missing architectural constraint: an architecture test or dependency rule, plus a short note in `docs/adr/`.
   - Missing context: the fact goes in the doc where the next session would look for it, or in the `## Project` section of `CLAUDE.md` if it is needed on almost every task.
   - Poor instruction: rewrite the rule in `CLAUDE.md`, shorter, with an example.
   - Ambiguous requirement: add the missing criterion to the plan, and note the pattern so `/plan` asks for it next time.
   - Excessive or insufficient autonomy: propose the exact `settings.json` line. Do not edit `.claude/` yourself; that is for a human to apply.
   - Model capability: split the task smaller, or note that a human does this step.
3. Implement the control now and prove it catches the original mistake (for example, the new test fails against the old behaviour and passes against the fix).
4. Append a row to `docs/ai-process-audit/lessons.md` (create it if needed): `date | what went wrong | root cause | control added | where`.
5. If the mistake was expensive, add a golden task to `docs/ai-process-audit/golden-tasks.md` so the next `/audit` measures whether it stays fixed.

Report: the control added, where it lives, and how you verified it.
