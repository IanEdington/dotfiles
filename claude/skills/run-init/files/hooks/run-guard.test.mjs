#!/usr/bin/env node
// Walks each role's permitted and forbidden tool calls through run-guard.mjs. Usage: node run-guard.test.mjs
// A row is [role, tool, input, expected], where expected is 'allow' or 'deny'; a role of 'quoted' has the
// controller mark only in its second prompt and must count as no role.
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const hook = new URL('./run-guard.mjs', import.meta.url).pathname;
const dir = mkdtempSync(join(tmpdir(), 'run-guard-'));
const repo = join(dir, 'repo');
mkdirSync(repo);
spawnSync('git', ['init', '-q', repo]);
spawnSync('git', ['-C', repo, 'checkout', '-q', '-b', 'main']);

const marks = {
  manager: 'You are the manager for o/r.',
  architect: 'You are the architect for o/r.',
  factory: 'You are the factory for o/r.',
  controller: 'You are the controller for o/r.',
  worker: 'You are a worker in the run on o/r.',
  reviewer: 'You are the reviewer for PR #1 on o/r.',
  auditor: 'You are the auditor for o/r.',
  quoted: 'hello',
};
const transcripts = {};
for (const [name, first] of Object.entries(marks)) {
  const path = join(dir, `${name}.jsonl`);
  const lines = [
    { type: 'user', message: { content: first } },
    { type: 'user', message: { content: 'Quoting: "You are the controller for o/r" is not a role.' } },
  ];
  writeFileSync(path, lines.map((line) => JSON.stringify(line)).join('\n') + '\n');
  transcripts[name] = path;
}

const inRepo = join(repo, 'src', 'x.php');
const state = { branch: 'claude/run-state' };
const rows = [
  ['reviewer', 'Edit', { file_path: inRepo }, 'deny'],
  ['reviewer', 'Edit', { file_path: '/tmp/x' }, 'allow'],
  ['reviewer', 'Bash', { command: 'git commit -m x' }, 'deny'],
  ['reviewer', 'Bash', { command: 'gh pr edit 3 --body x' }, 'deny'],
  ['reviewer', 'mcp__github__add_issue_comment', { body: 'Run report: reviewer' }, 'allow'],
  ['auditor', 'mcp__github__add_issue_comment', { body: 'Run report: auditor\naudited: #1' }, 'allow'],
  ['auditor', 'mcp__github__add_issue_comment', { body: 'Looks wrong to me' }, 'deny'],
  ['auditor', 'mcp__github__issue_write', { body: 'Paths: x' }, 'allow'],
  ['worker', 'mcp__github__merge_pull_request', { pullNumber: 1 }, 'deny'],
  ['worker', 'mcp__github__update_pull_request', { pullNumber: 7, body: 'Closes #3' }, 'allow'],
  ['worker', 'mcp__github__update_pull_request', { pullNumber: 2, body: 'Run: 2026. Controller: me. Handoff: requested' }, 'deny'],
  ['worker', 'mcp__github__issue_write', { issue_number: 2, body: 'Run: 2026. Controller: me.' }, 'deny'],
  ['worker', 'mcp__github__create_or_update_file', { path: 'docs/run/handoff.md', ...state }, 'deny'],
  ['worker', 'Bash', { command: 'git push -u origin claude/run-state' }, 'deny'],
  ['worker', 'Bash', { command: "gh api repos/o/r/pulls/2 -X PATCH -f body=x" }, 'deny'],
  ['worker', 'Bash', { command: 'gh api repos/o/r/pulls/2' }, 'allow'],
  ['worker', 'Edit', { file_path: inRepo }, 'allow'],
  ['architect', 'Edit', { file_path: join(repo, 'docs', 'plan.md') }, 'deny'],
  ['architect', 'mcp__github__create_or_update_file', { path: 'docs/run/holdout/5.md', ...state }, 'allow'],
  ['architect', 'mcp__github__create_or_update_file', { path: 'docs/run/handoff.md', ...state }, 'deny'],
  ['architect', 'mcp__github__create_or_update_file', { path: 'docs/run/holdout/5.md', branch: 'main' }, 'deny'],
  ['architect', 'mcp__github__create_branch', { branch: 'claude/run-state' }, 'allow'],
  ['architect', 'mcp__github__create_pull_request', { head: 'claude/run-state', base: 'main' }, 'allow'],
  ['architect', 'mcp__github__create_pull_request', { head: 'claude/x', base: 'main' }, 'deny'],
  ['architect', 'mcp__github__issue_write', { body: 'Paths: x' }, 'allow'],
  ['architect', 'mcp__github__sub_issue_write', { issue_number: 1 }, 'allow'],
  ['factory', 'mcp__github__issue_write', { body: 'x' }, 'deny'],
  ['factory', 'Edit', { file_path: inRepo }, 'deny'],
  ['controller', 'Edit', { file_path: inRepo }, 'deny'],
  ['controller', 'Edit', { file_path: join(repo, 'docs', 'run', 'questions.md') }, 'allow'],
  ['controller', 'mcp__github__create_or_update_file', { path: 'docs/run/handoff.md', ...state }, 'allow'],
  ['controller', 'mcp__github__update_pull_request', { pullNumber: 2, body: 'Run: 2026. Controller: me.' }, 'allow'],
  ['controller', 'Bash', { command: 'git push origin claude/x' }, 'deny'],
  ['manager', 'Edit', { file_path: inRepo }, 'allow'],
  ['quoted', 'Edit', { file_path: inRepo }, 'allow'],
  ['quoted', 'Bash', { command: 'git push -u origin claude/run-state' }, 'allow'],
];

let failed = 0;
for (const [who, tool, tool_input, expected] of rows) {
  const session_id = `test-${who}-${Math.random().toString(16).slice(2)}`;
  const run = (role) =>
    spawnSync('node', [hook, 'pre-tool'], {
      input: JSON.stringify({ session_id, transcript_path: transcripts[role], cwd: repo, tool_name: tool, tool_input }),
      env: { ...process.env, CLAUDE_PROJECT_DIR: repo },
      encoding: 'utf8',
    });
  const result = run(who);
  const got = result.stdout.includes('"deny"') ? 'deny' : 'allow';
  if (result.status !== 0 || got !== expected) {
    failed++;
    console.log(`FAIL ${who} ${tool} ${JSON.stringify(tool_input)}: expected ${expected}, got ${got}${result.stderr ? `\n${result.stderr}` : ''}`);
  }
  rmSync(`/tmp/run-role-${session_id}`, { force: true });
}

// A subagent of the architect inherits the architect's rules through the shared session id.
{
  const session_id = `test-sub-${Math.random().toString(16).slice(2)}`;
  const parent = join(dir, `${session_id}.jsonl`);
  writeFileSync(parent, JSON.stringify({ type: 'user', message: { content: marks.architect } }) + '\n');
  const agent = join(dir, 'agent-abc.jsonl');
  writeFileSync(agent, JSON.stringify({ type: 'user', message: { content: 'explore the repo' } }) + '\n');
  const result = spawnSync('node', [hook, 'pre-tool'], {
    input: JSON.stringify({ session_id, transcript_path: agent, agent_id: 'abc', cwd: repo, tool_name: 'Edit', tool_input: { file_path: inRepo } }),
    env: { ...process.env, CLAUDE_PROJECT_DIR: repo },
    encoding: 'utf8',
  });
  if (!result.stdout.includes('"deny"')) {
    failed++;
    console.log('FAIL architect subagent Edit in repo: expected deny');
  }
  rmSync(`/tmp/run-role-${session_id}`, { force: true });
}

// Permission prompts: denied for every role but the manager and an unmarked session.
for (const [who, expected] of [['worker', 'deny'], ['architect', 'deny'], ['manager', 'allow'], ['quoted', 'allow']]) {
  const session_id = `test-perm-${who}-${Math.random().toString(16).slice(2)}`;
  const result = spawnSync('node', [hook, 'permission'], {
    input: JSON.stringify({ session_id, transcript_path: transcripts[who], cwd: repo }),
    env: { ...process.env, CLAUDE_PROJECT_DIR: repo },
    encoding: 'utf8',
  });
  const got = result.stdout.includes('"deny"') ? 'deny' : 'allow';
  if (got !== expected) {
    failed++;
    console.log(`FAIL permission ${who}: expected ${expected}, got ${got}`);
  }
  rmSync(`/tmp/run-role-${session_id}`, { force: true });
}

rmSync(dir, { recursive: true, force: true });
console.log(failed === 0 ? `ok: ${rows.length + 5} checks` : `${failed} failed`);
process.exit(failed === 0 ? 0 : 1);
