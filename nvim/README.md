# nvim

Plain Neovim (0.12+) config on the built-in `vim.pack` manager.

- `lua/config/pack.lua` — the one plugin list; `nvim-pack-lock.json` pins revisions (commit it).
- `lua/plugins/*.lua` — one setup file per area, required in order from `init.lua`.
- Update: `:packupdate` (review, then `:write`). Remove: drop from the list, restart, `:packdel name`.
- Everything loads at startup; defer a plugin only if `nvim --startuptime` shows it's slow.
