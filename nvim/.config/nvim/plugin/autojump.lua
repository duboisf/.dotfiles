local fn = vim.fn
local utils = require("core.utils")

-- disable jumping to last position
local function disable_jump_to_last_position()
  vim.b.disable_jump_to_last_position = true
end

local autocmd = utils.autogroup('plugin#autojump', true)

local disabled_filetypes = { 'gitcommit', 'help', 'startify' }

-- Disable jumping to last position when writting git commit messages
autocmd(
  'FileType',
  disabled_filetypes,
  disable_jump_to_last_position,
  'Disable jump to last position for certain filetypes'
)

-- when opening a file, jump to the last position we were in that file (if there was one)
autocmd(
  'BufReadPost',
  "*",
  function()
    if vim.b.disable_jump_to_last_position then
      return
    end
    if fn.line("'\"") > 0 and fn.line("'\"") <= fn.line("$") then
      fn.execute('normal! g`\"')
    end
  end,
  'Jump to last position when reopening a buffer'
)
