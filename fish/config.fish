set -x EDITOR nvim
set -x PNPM_HOME $HOME/Library/pnpm
set -gx PYENV_VIRTUALENV_DISABLE_PROMPT 1
set -x LDFLAGS "-L$(brew --prefix)/lib"
set -x CFLAGS "-I$(brew --prefix)/include"
set -x SWIG_FEATURES "-I$(brew --prefix)/include"
set -x GOPATH $HOME/go
set -x ZELLIJ_AUTO_ATTACH true
set -x ZELLIJ_AUTO_EXIT true

fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/bin
fish_add_path $PNPM_HOME
fish_add_path /usr/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.luarocks/bin
fish_add_path $GOPATH/bin
fish_add_path $HOME/.cabal/bin
fish_add_path $HOME/.ghcup/bin

if set -q VIRTUAL_ENV
    echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
end

starship init fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

status --is-interactive; and rbenv init - fish | source

uv generate-shell-completion fish | source
uvx --generate-shell-completion fish | source

eval $(opam env)

