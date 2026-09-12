# Third-party notices

Beyond Autopilot vendors the following skills into `config/.claude/skills/`, unmodified apart from dropping repository-only files noted in each skill's `UPSTREAM.md`. They install into every project alongside our own skills. Each directory carries its licence. Refresh or upgrade them with `bash scripts/vendor-skills.sh`.

| Skill | Upstream | Commit | Licence |
|---|---|---|---|
| stripe-best-practices | https://github.com/stripe/ai/tree/583467aab18cc7113dcd2c2e20028fe73c26eaa3/skills/stripe-best-practices | 583467a | MIT (Copyright (c) 2024-2025 Stripe) |
| supabase-postgres-best-practices | https://github.com/supabase/agent-skills/tree/8331f910845103c08d51f6ca1d86ebb7d1f745e3/skills/supabase-postgres-best-practices | 8331f91 | MIT (Copyright (c) 2026 Supabase) |
| supabase | https://github.com/supabase/agent-skills/tree/8331f910845103c08d51f6ca1d86ebb7d1f745e3/skills/supabase | 8331f91 | MIT (Copyright (c) 2026 Supabase) |
| systematic-debugging | https://github.com/obra/superpowers/tree/b36e0829c6d0140e93cfef2ca599b1b07d4a7797/skills/systematic-debugging | b36e082 | MIT (Copyright (c) 2025 Jesse Vincent) |
| vercel-react-best-practices | https://github.com/vercel-labs/agent-skills/tree/063bee94c3f4df8453406c830b0a7df0f2860278/skills/react-best-practices | 063bee9 | MIT, declared in SKILL.md frontmatter (no LICENSE file upstream at this commit) |
| verification-before-completion | https://github.com/obra/superpowers/tree/b36e0829c6d0140e93cfef2ca599b1b07d4a7797/skills/verification-before-completion | b36e082 | MIT (Copyright (c) 2025 Jesse Vincent) |

Our own skills (`plan`, `review`, `lesson`, `audit`, `beyond-traps`), the hooks, the installer and the documentation are copyright Beyond. See the repository root for licence terms once chosen.
