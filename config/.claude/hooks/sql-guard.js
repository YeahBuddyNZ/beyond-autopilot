#!/usr/bin/env node
// PreToolUse guard for any MCP tool that runs SQL against a live database.
// Works with Supabase execute_sql, Cloudflare D1 query, Render Postgres query, and similar.
// exit 0 = allow, exit 2 = block (Claude sees the reason and must ask you).
// Fails closed: anything it cannot parse is blocked.

let raw = '';
process.stdin.on('data', d => raw += d);
process.stdin.on('end', () => {
  let q;
  try {
    const inp = JSON.parse(raw);
    const t = inp.tool_input || {};
    q = t.query ?? t.sql ?? t.statement ?? '';
  } catch { return block('could not parse hook input'); }
  if (typeof q !== 'string' || !q.trim()) return block('empty or non-string query');

  // strip comments and string literals so text inside a string cannot fool the checks
  const lc = q
    .replace(/--[^\n]*/g, ' ')
    .replace(/\/\*[\s\S]*?\*\//g, ' ')
    .replace(/'(?:[^']|'')*'/g, "''")
    .replace(/\$\$[\s\S]*?\$\$/g, "''")
    .replace(/\s+/g, ' ')
    .toLowerCase();

  const rules = [
    [/\bdrop\s+(table|schema|database|index|policy|function|trigger|view|type|extension|role|user)\b/, 'DROP statement'],
    [/\btruncate\b/, 'TRUNCATE'],
    [/\balter\s+(table|schema|database|role|user|policy|function|system)\b/, 'ALTER statement (use a migration)'],
    [/\bcreate\s+(role|user)\b/, 'role/user creation'],
    [/\b(grant|revoke)\b/, 'GRANT/REVOKE'],
    [/\b(create|alter|drop)\s+policy\b/, 'RLS policy change'],
    [/\b(enable|disable|force)\s+row\s+level\s+security\b/, 'RLS toggle'],
    [/\bsecurity\s+definer\b/, 'SECURITY DEFINER function'],
    [/\bwhere\s+(true|1\s*=\s*1)\b/, 'WHERE true'],
    [/\b(copy|pg_read_file|pg_ls_dir|lo_import|lo_export|pg_terminate_backend|pg_cancel_backend)\b/, 'file, COPY or backend control'],
    [/\bset\s+(role|session_authorization)\b/, 'role switch'],
  ];
  for (const [re, why] of rules) if (re.test(lc)) return block(why);

  // writes to protected schemas
  if (/\b(auth|storage|supabase_functions|vault|pg_catalog|information_schema|extensions|net|cron|realtime|graphql)\./.test(lc) &&
      /\b(delete|update|insert|merge)\b/.test(lc)) return block('write to a protected schema');

  // split on ; and check each statement
  for (const st of lc.split(';').map(s => s.trim()).filter(Boolean)) {
    if (/\bdelete\s+from\b/.test(st)) {
      if (!/\bwhere\b/.test(st)) return block('DELETE without WHERE');
      if (!/\bwhere\b.*\b[a-z_]*id\b/.test(st)) return block('DELETE must target an id column');
    }
    if (/\bupdate\s+[a-z_."]+\s+set\b/.test(st) && !/\bwhere\b/.test(st)) return block('UPDATE without WHERE');
    if (/\bmerge\s+into\b/.test(st)) return block('MERGE (review manually)');
  }
  process.exit(0);

  function block(why) {
    process.stderr.write(`sql-guard BLOCKED: ${why}. Ask before running this.\n`);
    process.exit(2);
  }
});
