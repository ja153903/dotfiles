function theme --description 'Set light or dark mode in Ghostty, Herdr, and Neovim'
    set -l function_file (path resolve (status filename))
    set -l dotfiles (path dirname (path dirname (path dirname $function_file)))
    command python3 "$dotfiles/scripts/theme.py" $argv
end
