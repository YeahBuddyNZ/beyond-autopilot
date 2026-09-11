# PROPOSED root CLAUDE.md for this repo (draft, not applied)

Applies once R1 is done and the payload is installed at the root. It is the payload rules plus the six lines specific to this repo, so a session here works the way a downstream session does.

---

# Beyond Autopilot: Claude Code working rules

These rules apply to every project. Project-specific detail goes in the `## Project` section at the bottom.

## Autopilot
- Do not ask for confirmation on routine steps. Read, edit, run, query, test, commit and move on.
- Stop and ask only when: a permission prompt fires, a step touches real user data beyond what you created this session, a fix has failed twice, or you are about to spend money or change what users can see.
- When you ask, ask one question with a recommended answer. Never a list of questions.
- Finish the whole task, then give one short summary: what changed, what you verified, anything I need to check.

## Workflow
- Anything bigger than a small change starts with `/plan`. The plan lives in `docs/plans/` and commits reference it.
- Before calling a task done, run `/review` and fix what it finds.
- When I correct you, or you catch a mistake of your own, run `/lesson` so it becomes a test, rule or hook rather than a memory.

## Code
- Work on a feature branch. Commit after each working change with a short message. Pushing and merging need my ok.
- Run the test suite or a build before calling anything finished.
- Match the existing style of the repo. Do not add dependencies without saying why.

## Style
- New Zealand English. No em dashes anywhere, including code comments and commit messages.
- Short replies. Lead with what you did, not what you are about to do.

## Project
- Name: Beyond Autopilot (this is the source repo for the payload, not a consumer of it)
- Run and test: `bash scripts/verify.sh` is the only entry point. It is what CI runs.
- Source of truth: `config/` is the payload. The root `.claude/` is the installed copy and must be byte-identical; `verify.sh` checks this. Edit `config/`, then run `bash install.sh .` to refresh the root copy.
- Every change to `config/` or `install.sh` gets a line in `CHANGELOG.md` saying where it came from.
- Known environment limits: the cloud GitHub proxy refuses repository-settings writes (rename, topics, description). Ask the owner to do those by hand.
- Do not add a `## Project` section to `config/CLAUDE.md`. Downstream repos fill that in.
