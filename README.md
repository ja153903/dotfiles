# Jaime's dotfiles

My macOS configs for Fish, Ghostty, Herdr, Rex, Neovim, Yazi, and Starship.
Borrow whatever you like.

## Setup

```sh
./setup.sh       # installs Homebrew, Neovim, Ghostty, and Herdr, then links configs into ~/.config
./setup-fish.sh  # installs Fish and makes it the default shell
```

`setup.sh` backs up any existing config to `<name>.bak` before linking.

## Switch light and dark themes

The `theme` Fish command switches Ghostty, Herdr, Rex, and Neovim together.

```fish
theme light
theme dark
theme toggle   # same as running `theme` with no argument
theme status   # print the current mode
```

| App     | Light                 | Dark            | How it updates                               |
| ------- | --------------------- | --------------- | -------------------------------------------- |
| Ghostty | Solarized Osaka Light | Solarized Osaka | Reloads through AppleScript                  |
| Herdr   | Solarized Light       | Solarized       | Runs `herdr server reload-config`            |
| Rex     | Alpine Milk           | Abyssal Trench  | Switches mode and theme in each running app  |
| Neovim  | Solarized Osaka Light | Solarized Osaka | Watches the saved mode and applies it live   |

The mode is saved in `nvim/theme-mode`, which Git ignores. Without that file,
the mode is dark. macOS appearance is never changed.

### One-time steps

- **Rex:** turn on Remote Control under Settings → Rex Server, or Rex rejects
  the switch.
- **Neovim:** restart open sessions once so they load the watcher, or run
  `:lua require("config.theme").setup()` in each one.

### If an app doesn't update

Apps that aren't running are skipped, and a stopped Herdr server stays
stopped. If a running app fails to update, `theme` prints the error and exits
with status 1. The saved configs still apply the next time that app starts. To
retry, run `theme light` or `theme dark`, because `theme toggle` would flip
the mode again.

### Details

- Requires Python 3. The script lives at `scripts/theme.py`.
- Reads configs from `$XDG_CONFIG_HOME`, or `~/.config` when that's unset.
- `HERDR_CONFIG_PATH` overrides the Herdr config location.
- Run the tests with `python3 -m unittest discover -s scripts/tests -v`.
