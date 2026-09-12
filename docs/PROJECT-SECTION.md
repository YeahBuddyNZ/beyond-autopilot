# Writing the Project section

The `## Project` section at the bottom of a repo's `CLAUDE.md` is the only always-on, project-specific context the AI gets. Five good lines there save an hour of guessing per task. Fifty lines of history there cost every task tokens for nothing. This guide comes from reading the instruction files of 23 Beyond projects and noting what earned its place.

## Keep it to what changes behaviour on almost every task

Rules only. Status lives in pull requests and `NOTES.md`; rationale lives in `docs/decisions`; open questions live in `docs/open-questions.md`; long build logs live nowhere (delete them). One project kept a 928-line `CLAUDE.md` that was mostly a dated diary; another split a `PROGRESS.md` that "mixed rules, status, history, open questions and a password in one file". Neither helped the next session.

## What earns a line

**Identity and stack, one line each.** Name (and the names it must never be called), stack, hosting, region, package manager.

**Run, test and gate.** The exact commands, and which one is the definition of done. Say what is deliberately excluded and why: "do not gate on `tsc --noEmit`, 44 tolerated errors; `vitest run` is the gate".

**Live infrastructure.** Project refs, the exact pooler host, ports, domains, and the names (never the values) of the environment variables the app needs.

**Dashboard settings that must match the code.** Auth redirect URLs, site URL, email provider, anything set in a console that a migration cannot carry, with how each fails when wrong.

**Domain invariants, with the bug that taught them.** "Five health states, there is no sixth." "Never compare an ownership rate against a wet rate; this shipped to screen once." "Only `admin_create_user` writes `auth.users`." A rule with its origin is believed; a rule without one is skimmed.

**Never-invent facts.** The client's phone number, address, opening hours, price list, and the instruction that anything not listed is unknown, not guessable. Point at `docs/domain-facts.md` if there is one.

**Safe targets for testing.** The demo workspace, the `zz_test_` prefix, the named test job, and the rule that production has to be asked for by name.

**Repo-specific autonomy boundaries** where they differ from the base. Pre-launch, migrations may be autonomous; post-launch, they ask. Say which phase this repo is in.

**Traps.** Platform quirks that have already bitten this repo, one line each: symptom, cause, fix. If the trap is general, propose it for the `beyond-traps` skill instead.

**Brand and copy constraints.** Fonts and required subsets (macrons need `latin-ext`), the accent colour and its contrast pairing, the dash rule, what tone the audience needs ("greasy hands in bad light").

**Regulatory or policy lines.** Clinical claims, financial outcomes, consent handling, who may write te reo Māori copy. These are "needs a human" lines.

## What does not belong

- Anything the base rules already say.
- Anything a check enforces (say "enforced by `arch:check`" and leave it at that).
- Dated progress notes, completed task lists, migration diaries.
- Secrets or keys, even "public" ones. Names of variables, never values.
- Speculation. If it is not settled, it goes in `docs/open-questions.md`.

## Shape

Aim for 15 to 40 lines. Tag each line if the repo uses tags: enforced, built but unguarded, decided but not built. One project makes a test fail if a cited check path does not exist; that is the standard to aim for.

## Example

```
## Project
- Name: Muster. Team app for a U15 rugby squad. Holds children's data; see the ten non-negotiables in docs/rules.md (enforced by tests named beside each).
- Stack: Next.js 16, ReUI, Supabase (project ref abcd1234, Sydney), Vercel. pnpm.
- Run and test: pnpm dev / pnpm test / pnpm verify (the gate, what CI runs).
- Database: pooler host aws-0-ap-southeast-2.pooler.supabase.com, port 6543 for the app, 5432 for migrations. Migrations: supabase migration new <name>; commit the file in the same change.
- Auth: passwordless (email link plus code). Verify the OTP in the browser, never in a server route. Redirect URLs in the dashboard must include every deployment URL; a missing one fails silently.
- Env var names: NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY (server only), RESEND_API_KEY.
- Test data: names prefixed zz_test_, deleted by id. The demo squad is "zz Test Squad".
- Traps: passkeys were dropped after Android enrolment failed; do not propose them again without a written decision.
- Copy: NZ English, macrons required, no dashes of any kind in site copy (client preference, enforced by copy:check).
```
