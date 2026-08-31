#!/usr/bin/env python3
"""UserPromptSubmit hook: warn once per threshold as the context window fills.

Hook input carries no token counts, so usage is derived from the last assistant
message in the transcript: input + cache_read + cache_creation is what that
request actually sent, which is the context at that moment. The transcript lags
the in-memory conversation by up to a turn, so this reads slightly low; `/context`
remains authoritative.
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
DEFAULT_WINDOW = 200_000


def window_for(model: str) -> int:
    override = os.environ.get("CLAUDE_CODE_AUTO_COMPACT_WINDOW")
    if override and override.isdigit():
        return int(override)
    for fragment, size in MODEL_WINDOWS.items():
        if fragment in model:
            return size
    return DEFAULT_WINDOW


def last_assistant_usage(transcript: Path) -> tuple[int, str] | None:
    for line in reversed(transcript.read_text().splitlines()):
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


def main() -> None:
    payload = json.load(sys.stdin)
    transcript = Path(payload.get("transcript_path", ""))
    if not transcript.is_file():
        return

    usage = last_assistant_usage(transcript)
    if usage is None:
        return
    tokens, model = usage
    window = window_for(model)
    percent = tokens * 100 // window

    crossed = [t for t in THRESHOLDS if percent >= t]
    if not crossed:
        return
    highest = max(crossed)

    state = Path(
        os.environ.get("XDG_RUNTIME_DIR", "/tmp"),
        f"claude-context-warning-{payload.get('session_id', 'unknown')}",
    )
    already = int(state.read_text()) if state.is_file() else 0
    if highest <= already:
        return
    state.write_text(str(highest))

    headline = (
        f"Context at ~{percent}% of the window ({tokens // 1000}k / {window // 1000}k)."
    )
    print(
        json.dumps(
            {
                "systemMessage": headline,
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": (
                        f"Context usage crossed {highest}%. {headline} Open your next reply "
                        "with this one line verbatim, before anything else, then answer "
                        f"normally: \"Heads up: {headline} /compact when convenient.\""
                    ),
                },
            }
        )
    )


if __name__ == "__main__":
    main()
