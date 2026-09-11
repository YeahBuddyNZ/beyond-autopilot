# Lessons

Corrections turned into controls. `/lesson` appends a row here. If the same mistake appears twice, the control did not work; pick a stronger one.

| date | what went wrong | root cause | control added | where |
| --- | --- | --- | --- | --- |
| 2026-09-11 | Installer re-run overwrote the filled-in Project section of CLAUDE.md while the docs claimed it was preserved | missing validation | End-to-end re-run test that appends to the Project section and asserts it survives | `scripts/verify.sh` |
| 2026-09-11 | verify.sh built its fixture tarball from tracked files only, so untracked new files were "missing" from the install | missing validation | Tarball built from tracked plus untracked files | `scripts/verify.sh` |
| 2026-09-11 | `node --test tests/` on Node 22 treats the directory as a test file and reports one failure | missing context | verify.sh is the only documented way to run tests and uses an explicit glob | `scripts/verify.sh`, `CONTRIBUTING.md` |
| 2026-09-11 | The em dash check in CONTRIBUTING.md contained a literal em dash and flagged itself | poor instruction | Byte-escaped pattern in the scan; docs no longer carry the literal | `scripts/verify.sh` |
| 2026-09-11 | Tried to rename the repo through the GitHub API after a probe returned 200; the cloud proxy refuses repository-settings writes | missing tool | Recorded as a known environment limit so no session tries again | `CLAUDE.md` Project section, `docs/decisions.md` |
| 2026-09-11 | A 22-file change was built with no plan on disk and no review pass, in the repo that mandates both | missing feedback loop | The repo now installs its own payload, so `/plan`, `/review` and `/lesson` are available here and verify.sh fails if the root copy drifts | `scripts/sync-root.sh`, `scripts/verify.sh` |
| 2026-09-12 | Shell guard treated a bare `env` as a wrapper with nothing after it and let it through | missing validation | Test case for bare `env`; wrapper stripping requires a following command | `tests/bash-guard.test.js` |
| 2026-09-12 | Shell guard blocked a documentation command because a backtick pair inside a heredoc looked like command substitution. Found the moment the root install made the guard live in this session | missing validation | Heredoc bodies are treated as data unless piped to a shell or SQL client; six test cases | `config/.claude/hooks/bash-guard.js`, `tests/bash-guard.test.js` |
