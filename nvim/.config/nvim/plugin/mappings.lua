local actions = require("duboisf.github.actions")

local set = vim.keymap.set

-- Alt-i either opens a popup with the current TreeSitter node or the current
-- highlight group under the cursor
set('n', '<A-i>', require('core.utils').inspect_highlight, {
  silent = true,
  desc = 'Inspect highlight under cursor'
})

set(
  'n',
  '<leader>ot',
  function() actions.UpdateTagsWithCommitSha({ "Flatbook" }) end,
  {
    desc = "Update GitHub Action tags with the associated tag's commit SHA",
    silent = true,
  }
)

set(
  'n',
  '<C-u>',
  function()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local char = vim.fn.strcharpart(line, col, 1)
    local code = vim.fn.char2nr(char)
    local next_char = vim.fn.nr2char(code + 1)
    print('char', char, 'code', code, 'next_char', next_char)
    vim.cmd([[normal! r]] .. next_char)
  end,
  {
    desc = "Increment character under cursor, supports unicode",
    silent = true,
  }
)
