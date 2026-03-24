#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# --- Install dependencies ---

install_homebrew() {
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to PATH for the rest of this script
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "Homebrew already installed."
    fi
}

install_packages() {
    local packages=(fish neovim starship ghostty)
    local to_install=()

    for pkg in "${packages[@]}"; do
        if ! brew list "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        echo "Installing: ${to_install[*]}..."
        brew install "${to_install[@]}"
    else
        echo "All packages already installed."
    fi
}

# --- Symlink configs ---

link() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
        local current
        current="$(readlink "$dest")"
        if [[ "$current" == "$src" ]]; then
            echo "  ok: $dest"
            return
        fi
        echo "  updating: $dest -> $src"
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        echo "  backing up: $dest -> ${dest}.bak"
        mv "$dest" "${dest}.bak"
    else
        mkdir -p "$(dirname "$dest")"
    fi

    ln -s "$src" "$dest"
    echo "  linked: $dest -> $src"
}

link_configs() {
    echo "Linking configs..."
    link "$DOTFILES_DIR/fish"          "$CONFIG_DIR/fish"
    link "$DOTFILES_DIR/ghostty"       "$CONFIG_DIR/ghostty"
    link "$DOTFILES_DIR/nvim"          "$CONFIG_DIR/nvim"
    link "$DOTFILES_DIR/starship.toml" "$CONFIG_DIR/starship.toml"
}

# --- Set fish as default shell ---

set_default_shell() {
    local fish_path
    fish_path="$(command -v fish)"

    if [[ "$SHELL" == "$fish_path" ]]; then
        echo "Fish is already the default shell."
        return
    fi

    if ! grep -qF "$fish_path" /etc/shells; then
        echo "Adding $fish_path to /etc/shells (requires sudo)..."
        echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
    fi

    echo "Setting fish as default shell..."
    chsh -s "$fish_path"
}

# --- Main ---

main() {
    echo "=== Dotfiles Setup ==="
    echo "Dotfiles directory: $DOTFILES_DIR"
    echo ""

    install_homebrew
    install_packages
    echo ""
    link_configs
    echo ""
    set_default_shell

    echo ""
    echo "Done! Restart your terminal to use the new config."
}

main
