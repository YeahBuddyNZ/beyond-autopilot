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

Underneath that sits a **SQL guard**: a hook that inspects every query sent to a database tool (Supabase, Cloudflare D1, Render Postgres) and fails closed on anything destructive.

On top of that sit four commands that give every project the same working discipline:

| Command | What it does |
|---|---|
| `/plan` | Writes a durable implementation plan with objective acceptance criteria before anything bigger than a small change. Plans live in `docs/plans/` and commits reference them |
| `/review` | An independent review pass with a fixed checklist before a task is called done. Findings ranked, verdict given, then fixed |
| `/lesson` | Turns a correction into a control that cannot be skipped: a test, a rule, a hook or a doc, in the right place, verified |
| `/audit` | A Principal Engineer grade review of how the AI is actually being used on a repo, producing a ranked list of the smallest changes that would make it materially better |

Findings from `/audit` that apply everywhere come back here, so the base gets better with every project.

## What's in the box

```
config/                          the installable payload (copied to the root of your repo)
  CLAUDE.md                      working rules for every project, plus a Project section to fill in
  .claude/settings.json          allow / ask / deny permissions and the hook wiring
  .claude/hooks/sql-guard.js     PreToolUse hook that blocks dangerous SQL
  .claude/commands/plan.md       /plan    durable implementation plan with acceptance criteria
  .claude/commands/review.md     /review  independent review pass before a task is called done
  .claude/commands/lesson.md     /lesson  turn a correction into a test, rule or hook
  .claude/commands/audit.md      /audit   the AI process audit
install.sh                       one-line installer (curl | bash), safe to re-run
scripts/verify.sh                the checks CI runs on every pull request
tests/                           SQL guard test suite
docs/
  INSTALL.md                     every install path: cloud session, local repo, whole machine
  USAGE.md                       what to expect day to day, and the four commands
  AUDIT.md                       running the AI process audit and acting on it
  OWNER-INTAKE.md                questionnaire to fill in before an audit
  TROUBLESHOOTING.md             when something still prompts, blocks, or fails
CONTRIBUTING.md                  how to add to this repo
SECURITY.md                      how to report a way past the controls
CHANGELOG.md                     what changed and which project or audit it came from
```

## Install in 60 seconds

**From a Claude Code cloud session**, paste this as your first message on the target repo:

```
Install Beyond Autopilot into this repo:

1. Run:
   curl -sL https://raw.githubusercontent.com/YeahBuddyNZ/autopilot-config-into-a-cloud/main/install.sh | bash
2. Fill in the "## Project" section at the bottom of CLAUDE.md with what you can see: name, stack, how to run and test, migration tool.
3. Commit as "Add Beyond Autopilot config" and push to the current branch.
4. Tell me when it's pushed and which branch.
```

**From your own machine**, inside the repo:

```
curl -sL https://raw.githubusercontent.com/YeahBuddyNZ/autopilot-config-into-a-cloud/main/install.sh | bash
```

Then merge to your default branch and start a fresh session. Cloud sessions load the config when they clone; local sessions load it on next launch.

The installer keeps any existing `CLAUDE.md` content (it lands under the Project section for you to tidy), backs up a `settings.json` it replaces, and verifies the SQL guard is working before it reports success. Full detail, plus a no-script fallback, in [docs/INSTALL.md](docs/INSTALL.md).

## Check it's working

In a fresh session on the repo:

1. Ask it to run `delete from public.some_table` with no WHERE against your database tool. It should come back **blocked by the guard**, not ask you to allow it.
2. Type `/` and you should see `plan`, `review`, `lesson` and `audit` in the command list.
3. Ask it to make a small edit and commit. It should do both without asking.

## Day to day

Give it whole tasks, not steps. Anything bigger than a small change starts with `/plan`. It reads, edits, runs, tests and commits, runs `/review` on its own work, then hands you one summary: what changed, what it verified, and anything you need to check. When it does stop to ask, it asks one question with a recommended answer. When you correct it, `/lesson` makes sure you only have to do that once. See [docs/USAGE.md](docs/USAGE.md).

## The audit

Every 60 to 90 days, fill in [docs/OWNER-INTAKE.md](docs/OWNER-INTAKE.md), drop it in the repo, and run `/audit`. You get an executive summary, a failure histogram, a maturity scorecard, the ten highest-value changes ranked, a stop-doing list, and draft artefacts ready to adopt. Read the summary and the stop-doing list first. Delete before you add.

Rules the audit says every project needs go into `config/CLAUDE.md`. Checks it says should be enforced become hooks or permissions. Procedures become commands. That loop is the point of this repo. See [docs/AUDIT.md](docs/AUDIT.md).

## Supported platforms

Permissions are pre-wired for the claude.ai connectors and local MCP servers for **Supabase, Vercel, Netlify, Render, Cloudflare, GitHub and Google Drive**, and for npm, pnpm, yarn, bun, Python and the Supabase CLI. Anything else falls back to Claude Code's default of asking. Adding a platform is a few lines in `settings.json`; see [CONTRIBUTING.md](CONTRIBUTING.md).

## Quality

Every pull request to this repo runs `scripts/verify.sh`: the settings file must parse, the SQL guard must pass its test suite (allowed queries allowed, dangerous ones blocked, hidden keywords in strings and comments caught, unparseable input blocked), and the installer must run end to end against the pull request's own payload, twice, to prove it is idempotent. The same script runs locally before you push.

## Requirements

- Claude Code (CLI, desktop, web, or IDE extension)
- Node.js on the machine that runs the session (Claude Code already needs it; the SQL guard uses it)
- curl and tar for the installer

---

<div align="center">

Beyond™ Autopilot is built and maintained by Beyond, Aotearoa New Zealand.

</div>
