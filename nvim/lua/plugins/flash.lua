return {
  {
    "folke/flash.nvim",
    config = function(_, opts)
      require("flash").setup(opts)

      -- flash reaches into Neovim's C internals over LuaJIT FFI. As of
      -- nvim 0.13.0-dev, `search_match_lines` and `search_match_endcol` are no
      -- longer exported symbols, so every match lookup throws:
      --   dlsym(RTLD_DEFAULT, search_match_lines): symbol not found
      -- Replace the three functions that touch those symbols. Drop this once
      -- flash.nvim handles it upstream.
      local ok_ffi = pcall(function()
        local ffi = require("ffi")
        ffi.cdef([[unsigned int search_match_lines;]])
        return ffi.C.search_match_lines
      end)

      if ok_ffi then
        return
      end

      local Hacks = require("flash.hacks")
      -- only used to preserve incsearch highlighting during `/`; losing it is cosmetic
      Hacks.save_incsearch_state = function() end
      Hacks.restore_incsearch_state = function() end

      -- derive the match end with searchpos() instead of reading it out of C
      local Search = require("flash.search")
      local Pos = require("flash.search.pos")
      function Search:_next(flags)
        flags = flags or ""
        local ok, pos = pcall(vim.fn.searchpos, self.state.pattern.search, flags)
        -- incomplete or invalid pattern
        if not ok or pos[1] == 0 then
          return
        end
        local e = vim.fn.searchpos(self.state.pattern.search, "ceWn")
        pos = Pos({ pos[1], pos[2] - 1 })
        return {
          win = self.win,
          pos = pos,
          end_pos = e[1] ~= 0 and Pos({ e[1], e[2] - 1 }) or pos,
        }
      end
    end,
  },
}
