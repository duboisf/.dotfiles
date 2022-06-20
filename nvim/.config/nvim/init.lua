local fn = vim.fn
local utils = require("core.utils")
local autogroup = utils.autogroup
local autocmd = utils.autocmd

-- Load plugins
require("cfg.packer")


function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(unpack(objects))
  return ...
end

function _G.reload_lua(module)
  package.loaded[module] = nil
  require(module)
end

-- Jump to last position when reopening a buffer
local group = autogroup('cfg#jump_to_last_position', true)
autocmd(group, 'Filetype', "*", function() vim.b.disable_jump_to_last_position = 1 end)
autocmd(group, 'BufReadPost', "*", function()
  if vim.b.disable_jump_to_last_position then
    return
  end
  if fn.line("'\"") > 0 and fn.line("'\"") <= fn.line("$") then
    fn.execute('normal! g`\"')
  end
end
  , {
  desc = 'Jump to last position when reopening a buffer'
})

vim.keymap.set('n', '<C-o>', function()
  local ts_utils = require'nvim-treesitter.ts_utils'
  local node = ts_utils.get_node_at_cursor(0, true)
  if not node then
    return
  end
  print(node:type())
end)

vim.cmd 'source ~/.config/nvim/startup.vim'

-- vim: sts=2 sw=2 ts=2 et
