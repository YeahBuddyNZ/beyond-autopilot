#!/usr/bin/env node
// SessionStart hook. Reports which Beyond Autopilot payload this repo runs and
// warns about the things that most often mean "it is installed but not working".
// Output goes into the session's context, so keep it to a few lines.
const fs = require('fs');
const path = require('path');

const root = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const lines = [];
const warn = m => lines.push(`WARNING: ${m}`);

let version = 'unknown';
try {
  const stamp = JSON.parse(fs.readFileSync(path.join(root, '.claude', 'autopilot.json'), 'utf8'));
  version = `${stamp.version} (installed ${String(stamp.installed_at).slice(0, 10)} from ${stamp.source})`;
} catch { warn('no .claude/autopilot.json stamp; re-run the installer so future sessions know which version this is'); }
lines.unshift(`Beyond Autopilot ${version}`);

for (const f of ['sql-guard.js', 'bash-guard.js']) {
  if (!fs.existsSync(path.join(root, '.claude', 'hooks', f))) warn(`.claude/hooks/${f} is missing; the guard for it is not active`);
}

try {
  const md = fs.readFileSync(path.join(root, 'CLAUDE.md'), 'utf8');
  if (!/^## Project/m.test(md)) warn('CLAUDE.md has no "## Project" section');
  else if (/## Project[\s\S]*<!-- Fill in per repo/.test(md)) warn('the "## Project" section of CLAUDE.md is still the template; fill it in (name, stack, run and test commands, migration tool)');
} catch { warn('CLAUDE.md is missing at the repo root'); }

if (!fs.existsSync(path.join(root, 'docs', 'plans'))) lines.push('Note: docs/plans/ does not exist yet; /plan will create it.');

process.stdout.write(lines.join('\n') + '\n');
