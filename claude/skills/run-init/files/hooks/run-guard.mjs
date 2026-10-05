#!/usr/bin/env node
// Hooks for the run process (docs/run/run-process.md): the rules agents broke while they were prose.
// Usage: run-guard.mjs pre-tool|stop|permission [role]. Agent definitions pass their role explicitly;
// the project settings call it without one and the role is derived (controller, or none).
import {
  closeSync,
  existsSync,
  openSync,
  readFileSync,
  readSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import { spawnSync } from 'node:child_process';
import { basename, isAbsolute, relative, resolve } from 'node:path';

const input = JSON.parse(readFileSync(0, 'utf8'));
const projectDir = process.env.CLAUDE_PROJECT_DIR || input.cwd || process.cwd();
const config = {
  base: 'main',
  check: '',
  controllerWritable: ['docs/run/'],
  processPaths: ['.claude/', 'docs/run/'],
  claudeMdIndexLine: '^[+-]- `docs/[^`]+`: ',
  controllerHandoffAt: 250_000,
  controllerHandoffHardAt: 300_000,
  ...readConfig(),
};
// The first sentence of the controller prompt in the controller skill; changing it there breaks detection.
const CONTROLLER_MARK = 'You are the controller for';
const STATE_BRANCH = 'claude/run-state';
const OUTPUT_LIMIT = 6_000;
// Anchored so "not approved" or a question that mentions merging never counts.
const APPROVAL = /^\s*(approved?|lgtm|merge it|ship it)\b/i;

function readConfig() {
  const path = resolve(projectDir, '.claude/run-config.json');
  if (!existsSync(path)) return {};
  try {
    return JSON.parse(readFileSync(path, 'utf8'));
  } catch {
    return {};
  }
}

function readSlice(path, fromEnd, bytes) {
  const size = statSync(path).size;
  const length = Math.min(size, bytes);
  const buffer = Buffer.alloc(length);
  const fd = openSync(path, 'r');
  try {
    readSync(fd, buffer, 0, length, fromEnd ? size - length : 0);
  } finally {
    closeSync(fd);
  }
  return buffer.toString('utf8').split('\n');
}

function parse(line) {
  try {
    return JSON.parse(line);
  } catch {
    return undefined;
  }
}

function text(content) {
  if (typeof content === 'string') return content;
  if (Array.isArray(content)) return content.map((block) => block.text ?? '').join('\n');
  return '';
}

// A hook fired inside a subagent must never be judged by the controller's rules.
function fromSubagent() {
  if (input.agent_id || input.agent_type) return true;
  return typeof input.transcript_path === 'string' && basename(input.transcript_path).startsWith('agent-');
}

function role() {
  const explicit = process.argv[3];
  if (explicit) return explicit;
  if (fromSubagent()) return 'subagent';
  const cache = `/tmp/run-role-${input.session_id}`;
  if (existsSync(cache)) return readFileSync(cache, 'utf8');
  if (!input.transcript_path || !existsSync(input.transcript_path)) return 'none';
  const prompts = readSlice(input.transcript_path, false, 512 * 1024)
    .map(parse)
    .filter((entry) => entry?.type === 'user' && !entry.isSidechain && !entry.isMeta)
    .map((entry) => text(entry.message?.content));
  if (prompts.length === 0) return 'none';
  const detected = prompts.slice(0, 3).some((p) => p.includes(CONTROLLER_MARK)) ? 'controller' : 'none';
  writeFileSync(cache, detected);
  return detected;
}

function contextTokens() {
  if (!input.transcript_path || !existsSync(input.transcript_path)) return 0;
  const lines = readSlice(input.transcript_path, true, 4 * 1024 * 1024);
  for (let i = lines.length - 1; i >= 0; i--) {
    const entry = parse(lines[i]);
    const usage = entry?.type === 'assistant' && !entry.isSidechain ? entry.message?.usage : undefined;
    if (usage) {
      return (
        (usage.input_tokens ?? 0) +
        (usage.cache_read_input_tokens ?? 0) +
        (usage.cache_creation_input_tokens ?? 0) +
        (usage.output_tokens ?? 0)
      );
    }
  }
  return 0;
}

function deny(reason) {
  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'deny',
        permissionDecisionReason: reason,
      },
    }),
  );
  process.exit(0);
}

function repoPath(path) {
  const rel = relative(projectDir, isAbsolute(path) ? path : resolve(projectDir, path));
  return rel.startsWith('..') || isAbsolute(rel) ? undefined : rel;
}

function controllerMayWrite(path) {
  const rel = repoPath(path);
  return rel === undefined || config.controllerWritable.some((prefix) => rel.startsWith(prefix));
}

function run(command, args) {
  const result = spawnSync(command, args, {
    cwd: projectDir,
    encoding: 'utf8',
    maxBuffer: 64 * 1024 * 1024,
  });
  return { ok: result.status === 0, output: `${result.stdout ?? ''}${result.stderr ?? ''}`.trim() };
}

function github(path) {
  const headers = ['-H', 'Accept: application/vnd.github+json'];
  if (process.env.GITHUB_TOKEN) headers.push('-H', `Authorization: Bearer ${process.env.GITHUB_TOKEN}`);
  // A hook that times out does not block, so a hung proxy must fail here instead.
  const result = run('curl', ['-sS', '--fail', '--max-time', '20', ...headers, `https://api.github.com/repos/${path}`]);
  if (!result.ok) throw new Error(`GitHub API ${path}: ${result.output.slice(0, 300)}`);
  return JSON.parse(result.output);
}

function githubList(path) {
  const items = [];
  for (let page = 1; page <= 30; page++) {
    const batch = github(`${path}${path.includes('?') ? '&' : '?'}per_page=100&page=${page}`);
    items.push(...batch);
    if (batch.length < 100) break;
  }
  return items;
}

function processChanges(files) {
  const indexLine = new RegExp(config.claudeMdIndexLine);
  return files
    .filter((file) => {
      // A rename out of a protected path changes it as surely as an edit does.
      const names = [file.filename, file.previous_filename].filter(Boolean);
      if (names.some((name) => config.processPaths.some((prefix) => name.startsWith(prefix)))) return true;
      if (!names.includes('CLAUDE.md')) return false;
      if (file.previous_filename && file.filename !== file.previous_filename) return true;
      if (!file.patch) return true;
      // The API's patch has no file headers, so every +/- line is content; an index line is ordinary.
      return file.patch.split('\n').filter((line) => /^[+-]/.test(line)).some((line) => !indexLine.test(line));
    })
    .map((file) => file.filename);
}

function approvedByOwner(repo, number, headSha) {
  const since = github(`${repo}/commits/${headSha}`).commit.committer.date;
  // Every session posts as the owner through the Claude app; only a comment made outside any app is the owner.
  return githubList(`${repo}/issues/${number}/comments`).some(
    (comment) =>
      comment.user?.type === 'User' &&
      !comment.performed_via_github_app &&
      comment.created_at > since &&
      APPROVAL.test(comment.body ?? ''),
  );
}

function checkProcessMerge(args) {
  const repo = `${args.owner}/${args.repo}`;
  const number = args.pullNumber ?? args.pull_number;
  let changes;
  try {
    const pull = github(`${repo}/pulls/${number}`);
    changes = processChanges(githubList(`${repo}/pulls/${number}/files`));
    if (changes.length === 0 || approvedByOwner(repo, number, pull.head.sha)) return;
  } catch (error) {
    deny(`Could not confirm that #${number} leaves the run process unchanged, so the merge is refused: ${error.message}`);
  }
  deny(
    `#${number} changes the run process (${changes.join(', ')}). The owner merges it, or approves it with a comment on the PR after its last commit; add it to the Questions list.`,
  );
}

function isStatePush(command) {
  const branch = run('git', ['rev-parse', '--abbrev-ref', 'HEAD']).output;
  return command.includes(STATE_BRANCH) || branch === STATE_BRANCH;
}

function checkBeforePush(command) {
  if (/--delete\b|\s-d\s/.test(command)) return;
  // The state branch holds markdown only; a full check on it only costs time.
  if (isStatePush(command) || !config.check) return;
  const check = run('bash', ['-c', config.check]);
  if (check.ok) return;
  deny(
    `Push blocked by the pre-push hook (.claude/hooks/run-guard.mjs): \`${config.check}\` failed. Fix, commit, and push again.\n\n${check.output.slice(-OUTPUT_LIMIT)}`,
  );
}

function stagedPaths(command) {
  const staged = run('git', ['diff', '--cached', '--name-only']).output.split('\n');
  const all = /\s(-a|--all)\b|\s-[a-zA-Z]*a[a-zA-Z]*\s/.test(command)
    ? run('git', ['diff', '--name-only']).output.split('\n')
    : [];
  return [...staged, ...all].filter(Boolean);
}

function preTool() {
  const tool = input.tool_name ?? '';
  const args = input.tool_input ?? {};
  const who = role();
  const readOnly = who === 'reviewer' || who === 'auditor';

  if (tool === 'Bash') {
    const command = args.command ?? '';
    if (readOnly && /\bgit\s+(commit|push|merge|rebase|reset\s+--hard)\b/.test(command)) {
      deny(`The ${who} never changes the repo; a review comment or an issue is its only write.`);
    }
    if (who === 'controller' && /\bgit\s+commit\b/.test(command)) {
      const outside = stagedPaths(command).filter((path) => !controllerMayWrite(path));
      if (outside.length > 0) {
        deny(`The controller commits only under ${config.controllerWritable.join(', ')}; this commit includes ${outside.join(', ')}.`);
      }
    }
    // Any session in this repo merges only through the checked tool.
    if (/\/pulls\/[^/\s]+\/merge\b|\bgh\s+pr\s+merge\b|mergePullRequest|enablePullRequestAutoMerge/.test(command)) {
      deny('Merge with the GitHub MCP `merge_pull_request` tool, so the process check runs.');
    }
    if (/\bgit\s+push\b/.test(command)) {
      // A clean `git merge` commits without `git commit`, so the commit guard alone lets a merge reach a work branch.
      if (who === 'controller' && !isStatePush(command)) {
        deny('The controller pushes only the run-state branch. A work branch that needs a merge or fix goes to a worker.');
      }
      checkBeforePush(command);
    }
    return;
  }

  if (['Edit', 'Write', 'NotebookEdit'].includes(tool)) {
    const path = args.file_path ?? args.notebook_path ?? '';
    // Scratch files outside the checkout (a probe test in /tmp) are fine; the repo is not.
    if (readOnly && repoPath(path) !== undefined) deny(`The ${who} never changes the repo; put scratch files under /tmp.`);
    if (who === 'controller' && !controllerMayWrite(path)) {
      deny(`The controller never writes product code, tests, or design docs; only ${config.controllerWritable.join(', ')} (${path}).`);
    }
    return;
  }

  if (readOnly && /__(merge_pull_request|create_pull_request|update_pull_request|create_or_update_file|push_files|delete_file|create_branch)$/.test(tool)) {
    deny(`The ${who} never changes the repo or its PRs.`);
  }
  if (who === 'auditor' && /__add_issue_comment$/.test(tool)) {
    deny('Auditors file issues with issue_write and never comment on PRs.');
  }
  if (who === 'worker' && /__merge_pull_request$/.test(tool)) {
    deny('Workers do not merge. Report `done`; the controller merges after review.');
  }
  if (/__merge_pull_request$/.test(tool)) checkProcessMerge(args);
  if (/__enable_pr_auto_merge$/.test(tool)) {
    deny('Auto-merge would bypass the process check; merge with `merge_pull_request` once the PR is ready.');
  }
  if (who === 'controller' && /__(create_or_update_file|push_files|delete_file)$/.test(tool)) {
    const paths = args.files ? args.files.map((file) => file.path) : [args.path ?? ''];
    const outside = paths.filter((path) => !controllerMayWrite(path));
    if (outside.length > 0) deny(`The controller writes only under ${config.controllerWritable.join(', ')}; refused: ${outside.join(', ')}.`);
  }
}

function stop() {
  // Blocking a stop re-runs the turn; never block the continuation this hook itself caused.
  if (input.stop_hook_active || role() !== 'controller') return;
  const tokens = contextTokens();
  // Each threshold fires once: the soft one asks for a handoff when no worker is mid-turn, the hard one now.
  const crossed = [config.controllerHandoffHardAt, config.controllerHandoffAt].find((limit) => {
    const marker = `/tmp/run-context-${input.session_id}-${limit}`;
    if (tokens <= limit || existsSync(marker)) return false;
    writeFileSync(marker, String(tokens));
    return true;
  });
  if (!crossed) return;
  const k = Math.round(tokens / 1000);
  const reason =
    crossed === config.controllerHandoffHardAt
      ? `Context is ${k}k, over the ${Math.round(crossed / 1000)}k hard limit. Hand off now as the controller skill's "Handoff and stopping" says, whatever is in flight (at depth 7, ask the owner for a new line instead).`
      : `Context is ${k}k, over the ${Math.round(crossed / 1000)}k handoff threshold. Hand off as the controller skill's "Handoff and stopping" says at the end of the next pass in which no worker is mid-turn.`;
  process.stdout.write(JSON.stringify({ decision: 'block', reason }));
}

function permission() {
  // Nobody watches a run, so a prompt would wait forever with no event to wake anyone.
  if (role() === 'none') return;
  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PermissionRequest',
        decision: {
          behavior: 'deny',
          message:
            'No one watches this session, so this permission prompt was denied automatically. Use a pre-approved form of the command or a narrower one; if none exists, report `blocked` naming the command.',
        },
      },
    }),
  );
}

if (process.argv[2] === 'pre-tool') preTool();
else if (process.argv[2] === 'stop') stop();
else if (process.argv[2] === 'permission') permission();
