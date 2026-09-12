<div align="center">

# Beyond™ Autopilot for Claude Code

**A production-safe operating standard for AI-assisted engineering.**

Drop-in configuration that lets Claude Code run routine work without prompts, stops it cold before anything that can hurt a live system, and ships with a built-in process audit so every project makes the next one better.

Maintained by [Beyond](https://gobeyond.co.nz)

</div>

---

## Why this exists

Claude Code out of the box asks permission for everything, so people either click "allow" on autopilot or turn the guardrails off. Neither is safe. Beyond Autopilot draws the line once, in a config file, so the AI is quiet on the routine and firm on the consequential:

| Tier | What happens | Examples |
|---|---|---|
| **Silent** | Runs without asking | Read, edit, run tests, local commits, SELECT and id-scoped writes, read-only cloud tools |
| **One tap** | Asks once, with a recommendation | Deploys, migrations, push and merge, env vars, cloud resource create or delete, npx, curl, rm, ssh, docker |
| **Blocked** | Cannot happen, even if asked | Reading .env or keys, force push, hard reset, git clean, db reset, sudo, editing .github or .claude |

Underneath that sit two **guards**, both fail-closed hooks with their own test suites. The SQL guard inspects every query sent to a database tool (Supabase, Cloudflare D1, Render Postgres). The shell guard inspects every shell command, however the flags are spelled, and applies the SQL rules to SQL on a command line too. The exact list of what each blocks is in `SECURITY.md`; the tests are the authoritative version.

On top of that sit four skills that give every project the same working discipline:

| Command | What it does |
|---|---|
| `/plan` | Writes a durable implementation plan with objective acceptance criteria before anything bigger than a small change. Plans live in `docs/plans/` and commits reference them |
| `/review` | An independent review pass with a fixed checklist before a task is called done. Findings ranked, verdict given, then fixed |
| `/lesson` | Turns a correction into a control that cannot be skipped: a test, a rule, a hook or a doc, in the right place, verified |
| `/audit` | A Principal Engineer grade review of how the AI is actually being used on a repo, producing a ranked list of the smallest changes that would make it materially better |

Findings from `/audit` that apply everywhere come back here, so the base gets better with every project.

Then there is the memory. The `beyond-traps` skill holds every platform trap that has cost a Beyond project a day, with the symptom and the fix, drawn from the instruction files and commit history of 23 repositories. The rules that recurred across those repos are in the base `CLAUDE.md`. And six third-party skills ride along, pinned and licensed: Supabase's Postgres and platform guides, Vercel's React best practices, Stripe's integration guide, and two working-discipline skills from Superpowers (verify before claiming done, and debug systematically instead of guessing).

## What's in the box

```
config/                          the installable payload (copied to the root of your repo)
  CLAUDE.md                      working rules for every project, plus a Project section to fill in
  .claude/settings.json          allow / ask / deny permissions and the hook wiring
  .claude/hooks/sql-guard.js     PreToolUse hook that blocks dangerous SQL
  .claude/hooks/bash-guard.js    PreToolUse hook that blocks destructive shell commands
  .claude/hooks/session-check.js SessionStart hook: reports the version, warns if the config is not active
  .claude/skills/plan/           /plan    durable implementation plan with acceptance criteria
  .claude/skills/review/         /review  independent review pass before a task is called done
  .claude/skills/lesson/         /lesson  turn a correction into a test, rule or hook
  .claude/skills/audit/          /audit   the AI process audit
  .claude/skills/beyond-traps/   the platform traps that have cost Beyond projects a day, with fixes
  .claude/skills/<vendored>/     six third-party skills, pinned and licensed (see THIRD-PARTY-NOTICES.md)
  docs/plans/, docs/ai-process-audit/   plan folder, eval log and lessons log (created once, never overwritten)
.claude/, CLAUDE.md              this repo's own installed copy of the payload (it runs what it ships)
install.sh                       one-line installer (curl | bash), safe to re-run
VERSION                          date-based version, stamped into .claude/autopilot.json on install
scripts/verify.sh                the checks CI runs on every pull request
scripts/sync-root.sh             refresh this repo's installed copy from config/
scripts/vendor-skills.sh         refresh the vendored third-party skills at their pinned commits
tests/                           guard test suites
docs/
  INSTALL.md                     every install path: cloud session, local repo, whole machine
  USAGE.md                       what to expect day to day, and the four commands
  AUDIT.md                       running the AI process audit and acting on it
  OWNER-INTAKE.md                questionnaire to fill in before an audit
  TROUBLESHOOTING.md             when something still prompts, blocks, or fails
  decisions.md                   why things are the way they are
  PROJECT-SECTION.md             how to write the Project section of a repo's CLAUDE.md
THIRD-PARTY-NOTICES.md           the vendored skills, their sources and licences
CONTRIBUTING.md                  how to add to this repo
SECURITY.md                      how to report a way past the controls
CHANGELOG.md                     what changed and which project or audit it came from
```

`config/` is the source of the payload. The root `.claude/` and `CLAUDE.md` are this repo's own installed copy, kept in step by `scripts/sync-root.sh` and checked by CI, so every rule and guard is felt here before it ships anywhere else.

## Install in 60 seconds

**From a Claude Code cloud session**, paste the install message from [docs/INSTALL.md](docs/INSTALL.md) as your first message on the target repo. It runs the one-liner below and fills in the Project section.

**From your own machine**, inside the repo:

```
curl -sL https://raw.githubusercontent.com/YeahBuddyNZ/beyond-autopilot/main/install.sh | bash
```

Then merge to your default branch and start a fresh session. Cloud sessions load the config when they clone; local sessions load it on next launch.

The installer keeps any existing `CLAUDE.md` content (it lands under the Project section for you to tidy), keeps your Project section and logs on re-runs, backs up a `settings.json` it replaces, and verifies both guards are working before it reports success. Full detail, plus a no-script fallback, in [docs/INSTALL.md](docs/INSTALL.md).

## Check it's working

Start a fresh session on the repo. The first thing you see is the session check: the payload version, and a warning if the Project section is unfilled or a guard is missing. Then:

1. Ask it to run `rm -rf build`. It should come back **blocked by the guard**, not ask you to allow it. Same for `delete from public.some_table` with no WHERE against your database tool.
2. Type `/` and you should see `plan`, `review`, `lesson`, `audit` and `beyond-traps` in the list, along with the vendored skills.
3. Ask it to make a small edit and commit. It should do both without asking.

## Day to day

Give it whole tasks, not steps. Anything bigger than a small change starts with `/plan`. It reads, edits, runs, tests and commits, runs `/review` on its own work, then hands you one summary: what changed, what it verified, and anything you need to check. When it does stop to ask, it asks one question with a recommended answer. When you correct it, `/lesson` makes sure you only have to do that once. See [docs/USAGE.md](docs/USAGE.md).

## The audit

Every 60 to 90 days, fill in [docs/OWNER-INTAKE.md](docs/OWNER-INTAKE.md), drop it in the repo, and run `/audit`. You get an executive summary, a failure histogram, a maturity scorecard, the ten highest-value changes ranked, a stop-doing list, and draft artefacts ready to adopt. Read the summary and the stop-doing list first. Delete before you add.

Want to see what the output looks like before you run it? The repo audited itself: [docs/ai-process-audit/AI-PROCESS-AUDIT.md](docs/ai-process-audit/AI-PROCESS-AUDIT.md) is a real quick-mode run on this codebase, findings and all.

Rules the audit says every project needs go into `config/CLAUDE.md`. Checks it says should be enforced become hooks or permissions. Procedures become commands. That loop is the point of this repo. See [docs/AUDIT.md](docs/AUDIT.md).

## Supported platforms

Permissions are pre-wired for the claude.ai connectors and local MCP servers for **Supabase, Vercel, Netlify, Render, Cloudflare, GitHub and Google Drive**, and for npm, pnpm, yarn, bun, Python and the Supabase CLI. Anything else falls back to Claude Code's default of asking. Adding a platform is a few lines in `settings.json`; see [CONTRIBUTING.md](CONTRIBUTING.md).

## Quality

Every pull request to this repo runs `scripts/verify.sh`: the settings file must parse, both guards must pass their test suites, the root copy must match `config/`, and the installer must run end to end against the pull request's own payload, twice, to prove a re-run keeps your Project section and your logs. The same script runs locally before you push. The repo also runs the audit on itself; see `docs/ai-process-audit/`.

## The guards

Both run as hooks before the tool executes, both fail closed, both have a test suite in `tests/`. What they block is listed once, in [SECURITY.md](SECURITY.md). To try one by hand:

```
echo '{"tool_input":{"command":"rm -rf build"}}' | node config/.claude/hooks/bash-guard.js
```

Exit code 2 with a BLOCKED message means it is working.

## Requirements

- Claude Code (CLI, desktop, web, or IDE extension)
- Node.js on the machine that runs the session (Claude Code already needs it; the SQL guard uses it)
- curl and tar for the installer

## About Beyond

Beyond Autopilot is built and maintained by [Beyond](https://gobeyond.co.nz), a New Zealand studio that designs and builds web apps, client portals and internal tools for New Zealand businesses, with AI-assisted engineering under exactly these controls. Every lesson in this repo came from a real Beyond project. If you would like this way of working on something of yours, start at [gobeyond.co.nz](https://gobeyond.co.nz).

---

<div align="center">

Beyond™ Autopilot is built and maintained by [Beyond](https://gobeyond.co.nz), Aotearoa New Zealand.

</div>
