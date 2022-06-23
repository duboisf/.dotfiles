local utils = require("core.utils")

-- Load plugins
require("cfg.packer")

local o = vim.o

o.laststatus = 3

if utils.startedByFirenvim() then
  -- Try to make nvim optimal when we only have an nvim window that's just 2-3 lines high
  -- Never show the status line
  o.laststatus = 0

  -- Don't show the line and column of the cursor position
  o.ruler = false

  -- Don't show open tabs and buffers on the first line
  o.showtabline = 0

  -- Reduce cmd lines to minimum. For now the min is 1 buf after
  -- https://github.com/neovim/neovim/pull/16251 gets released the
  -- min is going to be 0
  o.cmdheight = 1
end

-- vim.keymap.set('n', '<C-o>', function()
--   local ts_utils = require'nvim-treesitter.ts_utils'
--   local node = ts_utils.get_node_at_cursor(0, true)
--   if not node then
--     return
--   end
--   print(node:type())
-- end)

vim.cmd 'source ~/.config/nvim/startup.vim'

-- vim: sts=2 sw=2 ts=2 et
