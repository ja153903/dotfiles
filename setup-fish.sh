#!/usr/bin/env bash
# Installs fish and makes it the default shell. Run once, separately from setup.sh.
set -euo pipefail

if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Run ./setup.sh first." >&2
  exit 1
fi

if ! brew list fish &>/dev/null; then
  echo "Installing fish..."
  brew install fish
else
  echo "fish already installed."
fi

fish_path="$(command -v fish)"

if [[ "$SHELL" == "$fish_path" ]]; then
  echo "fish is already the default shell."
  exit 0
fi

if ! grep -qF "$fish_path" /etc/shells; then
  echo "Adding $fish_path to /etc/shells (requires sudo)..."
  echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
fi

echo "Setting fish as default shell..."
chsh -s "$fish_path"
echo "Done! Restart your terminal."
