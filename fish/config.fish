set -x EDITOR nvim
set -x PNPM_HOME $HOME/Library/pnpm
set -gx PYENV_VIRTUALENV_DISABLE_PROMPT 1
set -x LDFLAGS "-L$(brew --prefix)/lib"
set -x CFLAGS "-I$(brew --prefix)/include"
set -x SWIG_FEATURES "-I$(brew --prefix)/include"
set -x GOPATH $HOME/go

fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/bin
fish_add_path $PNPM_HOME
fish_add_path /usr/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.luarocks/bin
fish_add_path $GOPATH/bin
fish_add_path $HOME/.cabal/bin
fish_add_path $HOME/.ghcup/bin
fish_add_path $HOME/.rye/shims
fish_add_path $HOME/Downloads/roc_nightly-macos_apple_silicon-2024-06-12-a6f1408b5c9

if set -q VIRTUAL_ENV
    echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
end

starship init fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

status --is-interactive; and rbenv init - fish | source

# opam configuration
source /Users/jaimeabbariao/.opam/opam-init/init.fish >/dev/null 2>/dev/null; or true
echo -e "\nsource "(brew --prefix asdf)"/libexec/asdf.fish" >>~/.config/fish/config.fish


set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
set -gx PATH $HOME/.cabal/bin /Users/jaimeabbariao/.ghcup/bin $PATH # ghcup-env

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish

source /opt/homebrew/opt/asdf/libexec/asdf.fish
