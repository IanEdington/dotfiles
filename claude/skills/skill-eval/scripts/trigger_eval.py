#!/usr/bin/env python3
"""Measure whether an installed skill triggers against the real skill roster.

Runs `claude -p <query>` from a project root where the skill under test is
already installed, so it competes with every other skill the user actually
has, and records whether Claude invoked it. Optionally swaps in a candidate
description for the duration of the run.

Usage:
    python trigger_eval.py --skill-path ~/.claude/skills/foo \
        --eval-set queries.json [--project-root .] [--runs 3] \
        [--description "candidate text"] [--model claude-...] [--json out.json]

queries.json:
    [{"query": "...", "should_trigger": true}, ...]
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---\n", re.DOTALL)


def read_frontmatter(skill_md: Path) -> tuple[str, str]:
    match = FRONTMATTER_RE.match(skill_md.read_text())
    if not match:
        sys.exit(f"{skill_md}: no frontmatter")
    fields = {}
    for line in match.group(1).splitlines():
        if ":" in line and not line.startswith(" "):
            key, _, value = line.partition(":")
            fields[key.strip()] = value.strip().strip("\"'")
    return fields.get("name", skill_md.parent.name), fields.get("description", "")


def with_description(skill_md: Path, description: str):
    """Rewrite the description line in place; caller restores from the returned backup."""
    backup = Path(tempfile.mkdtemp()) / "SKILL.md"
    shutil.copy2(skill_md, backup)
    text = skill_md.read_text()
    quoted = json.dumps(description)
    new_text, count = re.subn(
        r"^description:.*(?:\n[ \t]+.*)*", f"description: {quoted}", text, count=1, flags=re.MULTILINE
    )
    if count != 1:
        sys.exit(f"{skill_md}: could not find a description line to replace")
    skill_md.write_text(new_text)
    return backup


def invoked_skill(event: dict, skill_name: str) -> bool:
    if event.get("type") != "assistant":
        return False
    for block in event.get("message", {}).get("content", []):
        if block.get("type") != "tool_use":
            continue
        tool, args = block.get("name"), block.get("input", {})
        if tool == "Skill" and args.get("skill", "").split(":")[-1] == skill_name:
            return True
        if tool == "Read" and args.get("file_path", "").endswith(f"/{skill_name}/SKILL.md"):
            return True
    return False


def run_query(query: str, skill_name: str, project_root: Path, model: str | None, timeout: int, max_turns: int) -> bool:
    cmd = ["claude", "-p", query, "--output-format", "stream-json", "--verbose", "--max-turns", str(max_turns)]
    if model:
        cmd += ["--model", model]
    # CLAUDECODE guards against nested interactive sessions; a subprocess is fine.
    env = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}
    proc = subprocess.Popen(cmd, cwd=project_root, env=env, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    try:
        for line in proc.stdout:
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            if invoked_skill(event, skill_name):
                return True
            if event.get("type") == "result":
                return False
        return False
    finally:
        if proc.poll() is None:
            proc.kill()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            pass


def evaluate(eval_set, skill_name, project_root, model, runs, workers, timeout, max_turns):
    tallies = {item["query"]: [] for item in eval_set}
    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = {
            pool.submit(run_query, item["query"], skill_name, project_root, model, timeout, max_turns): item["query"]
            for item in eval_set
            for _ in range(runs)
        }
        for future in as_completed(futures):
            query = futures[future]
            try:
                tallies[query].append(future.result())
            except Exception as exc:  # a crashed run counts as not triggered
                print(f"warning: {query[:60]!r}: {exc}", file=sys.stderr)
                tallies[query].append(False)

    rows = []
    for item in eval_set:
        hits = tallies[item["query"]]
        rate = sum(hits) / len(hits)
        expected = item["should_trigger"]
        rows.append({
            "query": item["query"],
            "should_trigger": expected,
            "trigger_rate": rate,
            "pass": rate >= 0.5 if expected else rate < 0.5,
        })
    return rows


def summarize(rows):
    positives = [r for r in rows if r["should_trigger"]]
    negatives = [r for r in rows if not r["should_trigger"]]
    mean = lambda xs: sum(xs) / len(xs) if xs else 0.0
    return {
        "recall": mean([r["trigger_rate"] for r in positives]),
        "false_positive_rate": mean([r["trigger_rate"] for r in negatives]),
        "passed": sum(r["pass"] for r in rows),
        "total": len(rows),
    }


def markdown(skill_name, description, rows, summary) -> str:
    out = [
        f"## Trigger eval: `{skill_name}`",
        "",
        f"Description under test: {description}",
        "",
        f"Recall on should-trigger: **{summary['recall']:.0%}**. "
        f"False positives on should-not: **{summary['false_positive_rate']:.0%}**. "
        f"{summary['passed']}/{summary['total']} queries pass.",
        "",
        "| Expected | Rate | Pass | Query |",
        "|---|---|---|---|",
    ]
    for r in rows:
        expected = "fire" if r["should_trigger"] else "stay silent"
        out.append(f"| {expected} | {r['trigger_rate']:.0%} | {'yes' if r['pass'] else 'no'} | {r['query'][:90]} |")
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--skill-path", required=True, type=Path)
    ap.add_argument("--eval-set", required=True, type=Path)
    ap.add_argument("--project-root", type=Path, default=Path.cwd(), help="cwd for claude -p; decides which project skills load")
    ap.add_argument("--description", help="candidate description to test instead of the installed one")
    ap.add_argument("--model")
    ap.add_argument("--runs", type=int, default=3)
    ap.add_argument("--workers", type=int, default=5)
    ap.add_argument("--timeout", type=int, default=90)
    ap.add_argument("--max-turns", type=int, default=3, help="enough to see the first tool decision; keeps cost bounded")
    ap.add_argument("--json", type=Path, help="also write full results here")
    args = ap.parse_args()

    skill_md = args.skill_path / "SKILL.md"
    if not skill_md.exists():
        sys.exit(f"no SKILL.md at {args.skill_path}")
    if not shutil.which("claude"):
        sys.exit("claude CLI not on PATH")

    skill_name, installed_description = read_frontmatter(skill_md)
    eval_set = json.loads(args.eval_set.read_text())

    backup = with_description(skill_md, args.description) if args.description else None
    try:
        rows = evaluate(eval_set, skill_name, args.project_root, args.model, args.runs, args.workers, args.timeout, args.max_turns)
    finally:
        if backup:
            shutil.copy2(backup, skill_md)

    summary = summarize(rows)
    description = args.description or installed_description
    print(markdown(skill_name, description, rows, summary))
    if args.json:
        args.json.write_text(json.dumps({"skill": skill_name, "description": description, "summary": summary, "results": rows}, indent=2))


if __name__ == "__main__":
    main()
