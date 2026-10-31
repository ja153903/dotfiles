# Jaime's dotfiles

These are my dotfiles. You can take inspiration from some of my configs.

`emacs/` contains my Doom Emacs configuration. `setup.sh` links it to
`~/.doom.d`. Keep the Doom Emacs installation separate, in `~/.config/emacs`.

## Switch terminal and editor themes

Link this repository's `fish`, `ghostty`, `herdr`, and `nvim` directories under
`~/.config`, then run these commands in Fish.

```fish
theme light
theme dark
theme toggle
theme status
```

Running `theme` without an argument toggles the current mode. The command uses
Atom One Light or Atom One Dark in Ghostty and One Light or One Dark in Herdr
and Neovim. It saves the mode in `nvim/theme-mode`, which Git ignores.
The default is dark when that file does not exist.

Ghostty reloads through its macOS AppleScript interface when it is running.
Herdr reloads its server and attached clients with `herdr server reload-config`.
A stopped Herdr server stays stopped. Rex switches each running app to its
light or dark appearance, which uses the themes picked in Rex's settings. Turn on
Remote Control under Rex Server in Rex's settings so the app accepts this.
Neovim sessions watch the saved mode and
apply changes without restarting. macOS appearance stays independent.

Restart existing Neovim sessions once to load the watcher, or run this in each
session after the `onedark` plugin has loaded.

```vim
:lua require("config.theme").setup()
```

The command requires Python 3 and uses `XDG_CONFIG_HOME`, or `~/.config` by
default. `HERDR_CONFIG_PATH` overrides the Herdr config path. If an app cannot
refresh, the command reports the error and exits with a failure status.
The saved configs still apply when that app next starts. Rerun `theme light`
or `theme dark` to retry the refresh without toggling again.

Run the command's isolated checks with `python3 -m unittest discover -s scripts/tests -v`.
