set -x EDITOR nvim
set -x PNPM_HOME $HOME/Library/pnpm
set -gx PYENV_VIRTUALENV_DISABLE_PROMPT 1
set -x LDFLAGS "-L$(brew --prefix)/lib"
set -x CFLAGS "-I$(brew --prefix)/include"
set -x SWIG_FEATURES "-I$(brew --prefix)/include"
set -x DEV $HOME/programming
set -x BPL $DEV/by-programming-languages

fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/bin
fish_add_path $PNPM_HOME
fish_add_path /usr/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.luarocks/bin
fish_add_path $HOME/.local/share/uv/python
fish_add_path ~/.local/share/uv/python/cpython-3.14.*/bin
fish_add_path ~/programming/by-programming-languages/roc_nightly-macos_apple_silicon-2025-09-09-d73ea109cc2

if set -q VIRTUAL_ENV
    echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

status --is-interactive; and rbenv init - fish | source

uv generate-shell-completion fish | source
uvx --generate-shell-completion fish | source

test -r '/Users/jaimeabbariao/.opam/opam-init/init.fish' && source '/Users/jaimeabbariao/.opam/opam-init/init.fish' >/dev/null 2>/dev/null; or true

