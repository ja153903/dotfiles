set -x EDITOR nvim
set -x PNPM_HOME $HOME/Library/pnpm
set -gx PYENV_VIRTUALENV_DISABLE_PROMPT 1
set -x LDFLAGS "-L$(brew --prefix openssl@1.1)/lib"
set -x CFLAGS "-I$(brew --prefix openssl@1.1)/include"
set -x SWIG_FEATURES "-I$(brew --prefix openssl@1.1)/include"
set -x GOPATH $HOME/go

fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/bin
fish_add_path $PNPM_HOME
fish_add_path /usr/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.luarocks/bin
fish_add_path $GOPATH/bin

if set -q VIRTUAL_ENV
    echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
end

starship init fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

status --is-interactive; and rbenv init - fish | source
