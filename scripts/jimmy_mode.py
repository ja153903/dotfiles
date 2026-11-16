#!/usr/bin/env python3
"""UserPromptSubmit hook for Claude Code and Codex: a toggleable Jimmy mode.

Type `jimmy on` / `jimmy off` / `jimmy status` as a prompt. While on, every
prompt gets a reminder to route through the jimmy skill.
"""

import json
import sys
from pathlib import Path

# ponytail: one global flag for every session in both tools; key by session_id if per-session is wanted
FLAG = Path.home() / ".local/state/jimmy-mode/on"

REMINDER = (
    "JIMMY MODE ON. Route this request through the Jimmy workflow: if the jimmy "
    "skill is not already loaded in this conversation, load it first (Claude Code: "
    "Skill `jimmy:jimmy`; Codex: `$jimmy`) and follow its playbook. Say "
    "`jimmy off` to disable."
)


def handle(prompt: str) -> str | None:
    cmd = prompt.strip().lower()
    if cmd == "jimmy on":
        FLAG.parent.mkdir(parents=True, exist_ok=True)
        FLAG.touch()
        return "Jimmy mode turned ON. Acknowledge in one line; do nothing else."
    if cmd == "jimmy off":
        FLAG.unlink(missing_ok=True)
        return "Jimmy mode turned OFF. Acknowledge in one line; do nothing else."
    if cmd == "jimmy status":
        state = "ON" if FLAG.exists() else "OFF"
        return f"Jimmy mode is {state}. Report that in one line; do nothing else."
    return REMINDER if FLAG.exists() else None


def main() -> None:
    try:
        prompt = json.load(sys.stdin).get("prompt", "")
    except (json.JSONDecodeError, AttributeError):
        return
    context = handle(prompt)
    if context:
        json.dump(
            {"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": context}},
            sys.stdout,
        )


if __name__ == "__main__":
    main()
