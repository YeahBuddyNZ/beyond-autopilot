# Phase 0: Inventory

Audited commit: 4dae6e3 (branch `claude/relaxed-archimedes-vi33oc`, ahead of `main` at 711a243). Mode: quick.

## 0.0 Size and target maturity

Solo owner, public repo, no user data, but the payload governs AI behaviour against live systems in every downstream project. Treat as "small team, customers depend on it": target 7 on verification, context, feedback loops and guardrails; 5 elsewhere.

## 0.1 Agent tooling detected

| Tool | Mechanism | Used | Notes |
| --- | --- | --- | --- |
| Claude Code | `CLAUDE.md` (root) | yes | 11 lines. Rules for editing this repo |
| Claude Code | `.claude/settings.json` (root) | **no** | The payload's permissions and SQL guard do not apply to sessions on this repo |
| Claude Code | `.claude/commands/` (root) | **no** | `/plan`, `/review`, `/lesson`, `/audit` are shipped but not available here |
| Claude Code | `.claude/hooks/` (root) | no | as above |
| Claude Code | `.claude/skills/`, `.claude/agents/` | no | Not needed at this size |
| GitHub Actions | `.github/workflows/verify.yml` | yes | Runs `scripts/verify.sh` on every PR and push to main |

Cheapest unused mechanism: installing the payload at this repo's own root. See R1.

## 0.2 Artefact inventory

| Artefact | Location | State | Size | Notes |
| --- | --- | --- | --- | --- |
| Repository instructions (this repo) | `CLAUDE.md` | Present | 11 lines | |
| Repository instructions (payload) | `config/CLAUDE.md` | Present | 45 lines | Always-on in downstream repos |
| Commands | `config/.claude/commands/*.md` | Present | 21 to 561 lines | Retrieved on demand, correct placement |
| Permissions and hooks | `config/.claude/settings.json` | Present | 168 lines, 55 allow / 59 ask / 30 deny, no overlaps | Untested beyond JSON parse |
| SQL guard | `config/.claude/hooks/sql-guard.js` | Present | 61 lines | 26 tests |
| Installer | `install.sh` | Present | 102 lines | End-to-end tested by verify.sh |
| Tests | `tests/sql-guard.test.js` | Present | 26 cases | Guard only |
| CI | `.github/workflows/verify.yml` | Present | | Not a required status check on `main` [inferred, confidence: medium; no branch protection visible] |
| ADRs | `docs/adr/` | Absent | | Decisions live in README prose and chat |
| Plans | `docs/plans/` | Absent | | The payload tells downstream repos to use them; this repo does not |
| Lessons log | `docs/ai-process-audit/lessons.md` | Absent | | `/lesson` would write here; never run on this repo |
| Eval log, golden tasks | | Absent | | Nothing measures whether a change to the payload helped |
| README, CHANGELOG, CONTRIBUTING, SECURITY | root | Present | | |
| LICENSE | root | Absent | | Owner decision pending |
| Session transcripts | | Not visible | | This session is the only one; it is the main evidence source below |

## 0.3 Repository analytics

- Commits: 5 over 2 days (1 initial, 2 feature, 1 merge, 1 follow-up). Too few for rates to mean anything.
- Fix ratio: 0 of 5 commit messages match the fix pattern. Misleading: four defects were found and fixed inside one session before the commit was made (see Phase 3). The git history hides them; the transcript shows them.
- Files per commit: 1, 10, 0, 22, 3. The 22-file commit is the whole rebrand in one go, with no plan on disk.
- Churn hotspot: `README.md` (4 of 5 commits).
- Instruction weight: always-on total in a downstream repo is 45 lines (`config/CLAUDE.md`). The 561-line audit is a command, loaded only when invoked. Correct.
- Traceability: 0 of 5 commits reference a plan, issue or ADR.
- Dead weight: 0 TODO or FIXME in code (3 hits are the audit prompt describing TODO counting).
