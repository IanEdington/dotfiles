#!/usr/bin/env python3
"""Summarize with/without-skill runs into a lift table.

Expects the workspace layout the skill-eval workflow produces:

    <workspace>/<eval-name>/{with_skill,without_skill}/grading.json
    <workspace>/<eval-name>/{with_skill,without_skill}/timing.json   (optional)

grading.json: {"expectations": [{"text": "...", "passed": true, "evidence": "..."}]}
timing.json:  {"total_tokens": 84852, "duration_ms": 23332}

Usage:
    python lift_report.py <workspace> [--json out.json]
"""

import argparse
import json
import sys
from pathlib import Path

ARMS = ("with_skill", "without_skill")


def load(path: Path) -> dict | None:
    return json.loads(path.read_text()) if path.exists() else None


def arm_stats(arm_dir: Path) -> dict | None:
    grading = load(arm_dir / "grading.json")
    if grading is None:
        return None
    expectations = grading.get("expectations", [])
    timing = load(arm_dir / "timing.json") or {}
    return {
        "passed": sum(1 for e in expectations if e.get("passed")),
        "total": len(expectations),
        "tokens": timing.get("total_tokens"),
        "seconds": (timing.get("duration_ms") or 0) / 1000 or None,
    }


def collect(workspace: Path) -> list[dict]:
    evals = []
    for eval_dir in sorted(p for p in workspace.iterdir() if p.is_dir()):
        arms = {arm: arm_stats(eval_dir / arm) for arm in ARMS}
        if all(v is None for v in arms.values()):
            continue
        evals.append({"name": eval_dir.name, **arms})
    if not evals:
        sys.exit(f"no grading.json found under {workspace}")
    return evals


def pct(stats: dict | None) -> str:
    if not stats or not stats["total"]:
        return "n/a"
    return f"{stats['passed']}/{stats['total']} ({stats['passed'] / stats['total']:.0%})"


def tokens(stats: dict | None) -> str:
    return f"{stats['tokens']:,}" if stats and stats["tokens"] else "n/a"


def totals(evals: list[dict], arm: str) -> dict:
    stats = [e[arm] for e in evals if e[arm]]
    passed = sum(s["passed"] for s in stats)
    total = sum(s["total"] for s in stats)
    tok = [s["tokens"] for s in stats if s["tokens"]]
    return {
        "pass_rate": passed / total if total else None,
        "passed": passed,
        "total": total,
        "mean_tokens": sum(tok) / len(tok) if tok else None,
        "evals_with_data": len(stats),
    }


def markdown(evals: list[dict], with_t: dict, without_t: dict) -> str:
    lines = ["## Lift report", "", "| Eval | With skill | Without | Tokens with | Tokens without |", "|---|---|---|---|---|"]
    for e in evals:
        lines.append(f"| {e['name']} | {pct(e['with_skill'])} | {pct(e['without_skill'])} | {tokens(e['with_skill'])} | {tokens(e['without_skill'])} |")
    lines.append("")
    if with_t["pass_rate"] is not None and without_t["pass_rate"] is not None:
        lift = (with_t["pass_rate"] - without_t["pass_rate"]) * 100
        lines.append(f"Assertion pass rate: with {with_t['pass_rate']:.0%}, without {without_t['pass_rate']:.0%}, **lift {lift:+.0f} pp** "
                     f"over {with_t['total']} assertions across {len(evals)} evals.")
    else:
        lines.append("Lift not computable: one arm has no graded runs.")
    if with_t["mean_tokens"] and without_t["mean_tokens"]:
        ratio = with_t["mean_tokens"] / without_t["mean_tokens"]
        lines.append(f"Mean tokens per run: with {with_t['mean_tokens']:,.0f}, without {without_t['mean_tokens']:,.0f} "
                     f"(**{ratio:.2f}x**).")
    lines.append("")
    lines.append("Caveat: each eval has one run per arm unless you ran more; treat single-digit assertion counts as directional, not significant.")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("workspace", type=Path)
    ap.add_argument("--json", type=Path)
    args = ap.parse_args()

    evals = collect(args.workspace)
    with_t, without_t = totals(evals, "with_skill"), totals(evals, "without_skill")
    print(markdown(evals, with_t, without_t))
    if args.json:
        args.json.write_text(json.dumps({"evals": evals, "with_skill": with_t, "without_skill": without_t}, indent=2))


if __name__ == "__main__":
    main()
