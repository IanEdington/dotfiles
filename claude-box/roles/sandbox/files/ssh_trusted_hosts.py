#!/usr/bin/env python3
"""PreToolUse hook on Bash: allows `ssh <trusted alias> <one argument>`, asks
before every other command that mentions ssh, scp, sftp, or rsync.

Usage: ssh_trusted_hosts.py <alias>... (hook input JSON on stdin)

The allowed form is matched against the raw command string rather than
tokenized, because a tokenizer can't tell a quoted `;` from a shell operator.
Anything outside the single remote-command argument (ssh flags, a second
command, redirects, expansions) runs on this machine outside the Bash sandbox,
so it must fall through to `ask`.
"""

import json
import re
import sys

ALIAS = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]*")

# The remote command: one single-quoted string, one double-quoted string with
# nothing the local shell expands, or one bare word with no glob, brace,
# tilde, or comment characters.
REMOTE_ARGUMENT = r"""(?:'[^']*'|"[^"$`\\!]*"|[A-Za-z0-9_./:=@%+,-]+)"""

ALLOWED = re.compile(
    rf"ssh[ \t]+(?P<alias>{ALIAS.pattern})[ \t]+(?P<argument>{REMOTE_ARGUMENT})"
)

REMOTE_SHELL = re.compile(r"(?<![\w.-])(ssh|scp|sftp|rsync)(?![\w.-])")


def unquote(argument: str) -> str:
    if argument[:1] in ("'", '"'):
        return argument[1:-1]
    return argument


def decide(command: str, trusted: set[str]) -> str | None:
    """Returns "allow", "ask", or None for commands this hook has no say in."""
    if not REMOTE_SHELL.search(command):
        return None
    match = ALLOWED.fullmatch(command.strip(" \t\n"))
    if not match or match["alias"] not in trusted:
        return "ask"
    remote = unquote(match["argument"])
    # ssh reads options after the host too, so `'-oProxyCommand=sh'` would run
    # locally once the shell strips the quotes. An empty command opens an
    # interactive shell.
    if not remote.strip() or remote.startswith("-"):
        return "ask"
    return "allow"


def respond(decision: str, reason: str) -> None:
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": decision,
                "permissionDecisionReason": reason,
            }
        },
        sys.stdout,
    )


def main() -> None:
    try:
        trusted = {alias for alias in sys.argv[1:] if ALIAS.fullmatch(alias)}
        hook_input = json.load(sys.stdin)
        command = hook_input["tool_input"]["command"]
        if not isinstance(command, str):
            raise TypeError("command is not a string")
        decision = decide(command, trusted)
    except Exception as error:  # noqa: BLE001 - any failure must ask, not allow
        respond("ask", f"ssh_trusted_hosts could not check this command: {error}")
        return
    if decision == "allow":
        respond("allow", "plain ssh to a trusted staging alias")
    elif decision == "ask":
        respond(
            "ask",
            "only `ssh <trusted alias> '<command>'` runs without asking",
        )


if __name__ == "__main__":
    main()
