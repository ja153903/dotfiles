#!/usr/bin/env python3
"""Synchronize the terminal and editor themes."""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile


THEMES = {
    "light": {"ghostty": "Atom One Light", "herdr": "one-light"},
    "dark": {"ghostty": "Atom One Dark", "herdr": "one-dark"},
}


def replace_setting(text, key, value):
    pattern = re.compile(r"^(\s*" + re.escape(key) + r"\s*=\s*)[^\n]*", re.MULTILINE)
    matches = list(pattern.finditer(text))
    if len(matches) != 1:
        raise ValueError("expected exactly one active %s setting" % key)
    return pattern.sub(lambda match: match.group(1) + value, text)


def herdr_theme(text, name):
    sections = list(re.finditer(r"^\[theme\][ \t]*(?:#.*)?$", text, re.MULTILINE))
    if len(sections) != 1:
        raise ValueError("expected exactly one [theme] section")
    start = sections[0].end()
    next_section = re.search(r"^\[", text[start:], re.MULTILINE)
    end = start + next_section.start() if next_section else len(text)
    section = replace_setting(text[start:end], "name", '"%s"' % name)
    if re.search(r"^\s*auto_switch\s*=", section, re.MULTILINE):
        section = replace_setting(section, "auto_switch", "false")
    else:
        section = "\nauto_switch = false" + section
    return text[:start] + section + text[end:]


def refresh(command, label):
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=15)
    except (OSError, subprocess.TimeoutExpired) as error:
        return "%s refresh failed: %s" % (label, error)
    if result.returncode:
        return "%s refresh failed: %s" % (label, result.stderr.strip() or result.stdout.strip())
    return None


def refresh_herdr():
    try:
        status = subprocess.run(["herdr", "status", "server", "--json"], capture_output=True, text=True, timeout=15)
        if status.returncode:
            return "Herdr status failed: %s" % (status.stderr.strip() or status.stdout.strip())
        if json.loads(status.stdout)["running"] is False:
            return None
    except (OSError, subprocess.TimeoutExpired, ValueError, KeyError) as error:
        return "Herdr status failed: %s" % error
    return refresh(["herdr", "server", "reload-config"], "Herdr")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", nargs="?", default="toggle", choices=[*THEMES, "toggle", "status"])
    args = parser.parse_args()
    config = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    mode_file = config / "nvim" / "theme-mode"
    try:
        current = mode_file.read_text().strip() if mode_file.exists() else "dark"
        if current not in THEMES:
            raise ValueError("invalid saved mode in %s" % mode_file)
        if args.mode == "status":
            print(current)
            return 0
        mode = ("light" if current == "dark" else "dark") if args.mode == "toggle" else args.mode
        ghostty = config / "ghostty" / "config"
        herdr = Path(os.environ.get("HERDR_CONFIG_PATH") or config / "herdr" / "config.toml").expanduser()
        updates = [
            (ghostty, replace_setting(ghostty.read_text(), "theme", THEMES[mode]["ghostty"])),
            (herdr, herdr_theme(herdr.read_text(), THEMES[mode]["herdr"])),
        ]
        if not mode_file.parent.is_dir():
            raise ValueError("Neovim config directory does not exist: %s" % mode_file.parent)
        for path, content in updates:
            path.write_text(content)
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(mode="w", dir=mode_file.parent, delete=False) as file:
                temporary = Path(file.name)
                file.write(mode + "\n")
            temporary.replace(mode_file)
        finally:
            if temporary is not None and temporary.exists():
                temporary.unlink()
    except (OSError, ValueError) as error:
        print("theme: %s" % error, file=sys.stderr)
        return 1

    ghostty_script = '''if application "Ghostty" is running then
    tell application "Ghostty"
        if (count of terminals) > 0 then
            set refreshed to perform action "reload_config" on first terminal
            if not refreshed then error "Ghostty rejected reload_config"
        end if
    end tell
end if'''
    errors = [error for error in [
        refresh(["osascript", "-e", ghostty_script], "Ghostty"),
        refresh_herdr(),
    ] if error]
    print("Theme set to %s." % mode)
    for error in errors:
        print("theme: %s. Configs are saved; rerun 'theme %s' to retry." % (error, mode), file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
