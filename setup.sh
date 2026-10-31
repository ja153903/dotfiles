#!/usr/bin/env bash
# Installs Homebrew and core apps, then links configs into ~/.config.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
PACKAGES=(neovim ghostty herdr)
CONFIGS=(fish ghostty herdr nvim rex starship.toml yazi)

install_homebrew() {
  if command -v brew &>/dev/null; then
    echo "Homebrew already installed."
    return
  fi
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for the rest of this script
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
}

install_packages() {
  local missing=()
  for pkg in "${PACKAGES[@]}"; do
    brew list "$pkg" &>/dev/null || missing+=("$pkg")
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "All packages already installed."
    return
  fi
  echo "Installing: ${missing[*]}..."
  brew install "${missing[@]}"
}

link() {
  local src="$1" dest="$2"
  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      echo "  ok: $dest"
      return
    fi
    echo "  updating: $dest -> $src"
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    echo "  backing up: $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -s "$src" "$dest"
  echo "  linked: $dest -> $src"
}

echo "=== Dotfiles Setup ==="
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""
install_homebrew
install_packages
echo ""
echo "Linking configs..."
mkdir -p "$CONFIG_DIR"
for name in "${CONFIGS[@]}"; do
  link "$DOTFILES_DIR/$name" "$CONFIG_DIR/$name"
done
