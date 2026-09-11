// Tests for the SQL guard hook. Run with: node --test tests/*.test.js
const { test } = require('node:test');
const assert = require('node:assert');
const { spawnSync } = require('node:child_process');
const path = require('node:path');

const HOOK = path.join(__dirname, '..', 'config', '.claude', 'hooks', 'sql-guard.js');

function run(query) {
  const input = query === null ? 'not json' : JSON.stringify({ tool_input: { query } });
  const r = spawnSync('node', [HOOK], { input, encoding: 'utf8' });
  return { code: r.status, err: r.stderr };
}

const allowed = [
  'select * from public.users where id = 1',
  'select count(*) from orders',
  "insert into public.notes (title) values ('zz_test_one')",
  'update public.users set name = \'x\' where id = 42',
  'delete from public.users where id = 42',
  'delete from public.sessions where user_id in (1, 2)',
  "select * from t where note = 'drop table users'",
  'select 1 -- drop table users',
];

const blocked = [
  ['delete from public.users', 'DELETE without WHERE'],
  ['delete from public.users where name = \'bob\'', 'DELETE must target an id column'],
  ['update public.users set active = false', 'UPDATE without WHERE'],
  ['drop table public.users', 'DROP statement'],
  ['truncate public.users', 'TRUNCATE'],
  ['alter table public.users add column x int', 'ALTER statement'],
  ['grant all on public.users to anon', 'GRANT/REVOKE'],
  ['create policy p on public.users for select using (true)', 'RLS policy change'],
  ['alter table public.users enable row level security', 'ALTER statement'],
  ['delete from public.users where true', 'WHERE true'],
  ['delete from public.users where 1=1', 'WHERE true'],
  ['delete from auth.users where id = 1', 'write to a protected schema'],
  ['select 1; drop table public.users', 'DROP statement'],
  ["select 1 /* */; truncate public.users", 'TRUNCATE'],
  ['merge into public.users u using s on u.id = s.id when matched then update set x = 1', 'MERGE'],
  ['set role postgres', 'role switch'],
  ['', 'empty'],
];

for (const q of allowed) {
  test(`allows: ${q}`, () => {
    const r = run(q);
    assert.strictEqual(r.code, 0, r.err);
  });
}

for (const [q, why] of blocked) {
  test(`blocks (${why}): ${q || '<empty>'}`, () => {
    const r = run(q);
    assert.strictEqual(r.code, 2, `expected block, got exit ${r.code}`);
    assert.match(r.err, /sql-guard BLOCKED/);
  });
}

test('blocks unparseable hook input (fails closed)', () => {
  const r = run(null);
  assert.strictEqual(r.code, 2);
});
