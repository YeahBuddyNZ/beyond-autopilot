# What kinds of skill belong here, and why

A skill is a folder with a `SKILL.md` that Claude Code loads when a task matches its description. Its description sits in every session's context, always; its body loads only when it fires. That shape decides what belongs in one. This page is about kinds, not names: the specific skills in the payload today are instances, and they will change.

## First, the things that are not skills

Most of what people put in a skill belongs somewhere cheaper or stronger. Sort by kind before writing one.

| Kind | What it is | Where it belongs |
|---|---|---|
| **Policy** | A rule the AI must obey every time: never force-push, never read `.env` | A permission or a hook. Enforced, not remembered. Our guards are this |
| **Instruction** | A standing preference: NZ English, ask one question not five | One line in `CLAUDE.md`, the always-on file, if it is needed on nearly every task |
| **Capability** | Something to execute: a check, a build, a query | A script or a test the AI can run, wired into `verify` or CI |
| **Knowledge** | Facts and traps that matter only when the task touches them | A retrievable skill or a doc, never the always-on file |
| **Procedure** | Steps with inputs, outputs and a way to tell it worked | A skill. This is the one kind a skill is actually for |

A skill that is really a policy will be ignored at the worst moment; make it a hook. A skill that is really an instruction wastes a load on every fire; make it a line. A skill that describes a system with no steps ("README as skill") fires and changes nothing; make it knowledge with a trigger, or delete it.

## The four kinds this payload carries

### 1. Working discipline: procedures at lifecycle moments

Procedures that fire at the three points where AI work most often goes wrong: before it starts, before it is called done, and after it was corrected. They are stack-agnostic, apply to every project, and each one exists because a specific failure was observed across projects: plans that lived only in chat, "done" declared on a green typecheck, the same correction made three times.

What qualifies: a procedure with numbered steps, an artefact it produces (a plan file, a findings list, a lessons row), and a verification of its own. What disqualifies: a checklist with no output, or steps the AI already follows without being told.

Skills of this kind that write files are user-invoked only (`disable-model-invocation: true`), so the model cannot start creating plans or rules on its own.

### 2. Memory: knowledge earned by a shipped defect

One skill per organisation that holds the traps that have already cost a real project a day, each with the symptom, the fix and the repo it came from. Read, not run. It is the answer to "the AI keeps making the same platform mistake in every new repo", and it is the part of this payload that no one else can write for us.

What qualifies: a trap that bit a real project, stated as symptom then fix, general enough to bite the next project. What disqualifies: anything specific to one repo (that goes in that repo's `## Project` section), anything already enforced by a guard, and anything not yet observed (a guess about what might go wrong is not memory).

### 3. Platform guides: knowledge from the vendor

Official or widely maintained guidance for the platforms in the stack, vendored at a pinned commit with its licence. Supabase knows more about Supabase than we do; the value is in having the right guide load when the task touches that platform, and in not writing it ourselves.

What qualifies: the platform is in active use across projects; the guide is maintained by the vendor or has clear, broad adoption; the licence permits redistribution inside a client-installed payload (MIT or similar); the skill is self-contained (no services to run, no keys to hold); the body is under the 500-line limit. What disqualifies: a platform used in one project, a share-alike or unclear licence, a guide that assumes tooling we do not ship, or one whose description overlaps a skill already present so that both fire.

Vendored means unmodified. Fixes go upstream, or the skill is dropped.

### 4. Process audit: a procedure over the process itself

One skill that audits how the AI is being used on a repo rather than the code, and produces a ranked list of the smallest changes that would help. It is the feedback loop for everything above: findings that apply everywhere come back into this payload as rules, guards, traps or skills.

There is exactly one of these. A second one would be a sign the first is not doing its job.

## Kinds deliberately not carried

- **Persona and agent packs.** A builder, a reviewer, a tester and an architect as separate skills, with no evidence any catches what the builder missed. One independent review pass with a checklist does the job; roles are added only when a named failure class justifies one.
- **Memory systems that need infrastructure.** Vector stores, local daemons, databases, five lifecycle hooks. A lessons file on disk and a traps skill cover an agency's needs at no running cost.
- **Bulk collections.** Hundreds of generic skills, each description paid for in every session, most never firing. A skill that never fires is maintenance with no return.
- **Anything that duplicates a check.** If `verify` or a hook already enforces it, a skill saying it again is noise, and worse, it invites the AI to believe the instruction is the control.
- **Style and quality boosters without a failure.** "Write better code" skills. Nothing in the histogram traces to them, so they cannot be measured, so they do not go in.
- **Guides for stacks not in use.** Every description costs context in every project, including the ones that will never touch that platform.
- **Anything over the limits.** Body over 500 lines, description over 1,536 characters. Detail goes in `references/` beside the skill, loaded only when needed.
- **Unclear or share-alike licences.** The payload is installed into client repositories; anything vendored has to be safe to redistribute there.

## The bar for adding one

1. Name the failure. Which lesson row, audit finding or shipped defect does this skill prevent? If none, it waits until one exists.
2. Check the cheaper control first. Could a permission, a hook, a test or one line in `CLAUDE.md` prevent the same failure? If yes, do that instead.
3. Check it recurs. A trap in one repo is a `## Project` line. It earns a place in the base when it recurs across projects or the defect shipped.
4. Pay the always-on cost knowingly. Ten skills cost roughly a thousand words in every session before any work starts. Each new one has to earn that against the others.
5. Write the description as the trigger: what it does, the situations and phrasings it fires on, and what it is not for. The docs say Claude under-triggers on terse descriptions.
6. Keep it in shape: frontmatter, body under 500 lines, references beside it, a licence if vendored. `verify.sh` checks these.
7. Measure it. The right follow-up for our own skills is an evaluation set per skill: a few realistic prompts, graded with and without the skill. Until that exists, the eval log and re-audit are the measure.

## Where each kind lives

| Kind | Path | Verified by |
|---|---|---|
| Working discipline, memory, audit | `config/.claude/skills/<name>/SKILL.md` | `verify.sh`: frontmatter, limits, root copy matches |
| Platform guides | same path, via `scripts/vendor-skills.sh` | `verify.sh`: pinned commit, licence, listed in `THIRD-PARTY-NOTICES.md` |
| Policies | `config/.claude/hooks/`, `config/.claude/settings.json` | `tests/` and the installer's self-check |
| Instructions | `config/CLAUDE.md` | line count, the audit |
| Project-only knowledge | the downstream repo's `## Project` section | that repo's session check |
