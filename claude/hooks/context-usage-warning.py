#!/usr/bin/env python3
"""UserPromptSubmit hook: warn once per threshold as the context window fills.

Cloud sessions render no status line, so nothing otherwise signals that context
is filling until auto-compaction fires.

Hook input carries no token counts, so usage is derived from the last assistant
message in the transcript: input + cache_read + cache_creation is what that
request actually sent, which is the context at that moment. That matches the
figure `/context` reports.
"""

import json
import os
import sys
from pathlib import Path

THRESHOLDS = (50, 80)

MODEL_WINDOWS = {
    "opus-5": 1_000_000,
    "sonnet-5": 1_000_000,
    "fable-5": 1_000_000,
    "haiku-4-5": 200_000,
}
ASSUMED_WINDOW = 200_000

# Enough to reach a recent assistant message without reading a session-long
# transcript on every prompt.
TAIL_BYTES = 256 * 1024


def window_for(model: str) -> tuple[int, bool]:
    """Returns the window and whether it is a guess rather than a known value."""
    override = os.environ.get("CLAUDE_CODE_AUTO_COMPACT_WINDOW", "")
    if override.isdigit() and int(override) > 0:
        return int(override), False
    for fragment, size in MODEL_WINDOWS.items():
        if fragment in model:
            return size, False
    return ASSUMED_WINDOW, True


def tail_lines(path: Path) -> list[str]:
    with path.open("rb") as fh:
        fh.seek(0, os.SEEK_END)
        start = max(0, fh.tell() - TAIL_BYTES)
        fh.seek(start)
        chunk = fh.read()
    lines = chunk.decode("utf-8", errors="replace").splitlines()
    return lines[1:] if start else lines


def last_assistant_usage(transcript: Path) -> tuple[int, str] | None:
    for line in reversed(tail_lines(transcript)):
        if '"usage"' not in line:
            continue
        try:
            message = json.loads(line).get("message", {})
        except json.JSONDecodeError:
            continue
        usage = message.get("usage")
        if not usage:
            continue
        tokens = (
            usage.get("input_tokens", 0)
            + usage.get("cache_read_input_tokens", 0)
            + usage.get("cache_creation_input_tokens", 0)
        )
        return tokens, message.get("model", "")
    return None


def highest_crossed(percent: int, state: Path) -> int | None:
    crossed = [t for t in THRESHOLDS if percent >= t]
    if not crossed:
        return None
    highest = max(crossed)
    try:
        already = int(state.read_text())
    except (OSError, ValueError):
        already = 0
    if highest <= already:
        return None
    state.write_text(str(highest))
    return highest


def warn() -> None:
    payload = json.load(sys.stdin)
    transcript = Path(payload.get("transcript_path", ""))
    if not transcript.is_file():
        return

    usage = last_assistant_usage(transcript)
    if usage is None:
        return
    tokens, model = usage
    window, assumed = window_for(model)
    percent = tokens * 100 // window

    state = Path(
        os.environ.get("XDG_RUNTIME_DIR", "/tmp"),
        f"claude-context-warning-{payload.get('session_id', 'unknown')}",
    )
    highest = highest_crossed(percent, state)
    if highest is None:
        return

    qualifier = f", assuming a {window // 1000}k window for {model}" if assumed else ""
    headline = (
        f"Context at ~{percent}% of the window "
        f"({tokens // 1000}k / {window // 1000}k{qualifier})."
    )
    print(
        json.dumps(
            {
                "systemMessage": headline,
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": (
                        f"Context usage crossed {highest}%. Open your next reply with "
                        "this line verbatim, before anything else, then answer "
                        f'normally: "Heads up: {headline} /compact when convenient."'
                    ),
                },
            }
        )
    )


if __name__ == "__main__":
    try:
        warn()
    except Exception as exc:  # never let a warning interfere with the prompt
        print(f"context-usage-warning: {exc}", file=sys.stderr)
