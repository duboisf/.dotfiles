local fn = vim.fn
local utils = require("core.utils")
local autogroup = utils.autogroup
local autocmd = utils.autocmd

-- Jump to last position when reopening a buffer
local group = autogroup('cfg#autojump', true)

local disabledFiletypes = {'gitcommit', 'help', 'startify'}
-- Disable jumping to last position when writting git commit messages
autocmd(group, 'FileType', disabledFiletypes, function()
  vim.b.disable_jump_to_last_position = true
end)

-- when opening a file, jump to the last position we were in that file (if there was one)
autocmd(
  group,
  'BufReadPost',
  "*",
  function()
    if vim.b.disable_jump_to_last_position then
      return
    end
    if fn.line("'\"") > 0 and fn.line("'\"") <= fn.line("$") then
      fn.execute('normal! g`\"')
    end
  end
  ,
  {
    desc = 'Jump to last position when reopening a buffer'
  }
)

