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

--- Navigate to the next or previous sibling file in the same directory.
---@param direction 1|-1
local function sibling_file(direction)
  local current = vim.api.nvim_buf_get_name(0)
  if current == '' then return end
  local dir = vim.fn.fnamemodify(current, ':h')
  local name = vim.fn.fnamemodify(current, ':t')
  local entries = {}
  for entry, type in vim.fs.dir(dir) do
    if type == 'file' then
      table.insert(entries, entry)
    end
  end
  table.sort(entries)
  local idx
  for i, entry in ipairs(entries) do
    if entry == name then
      idx = i
      break
    end
  end
  if not idx then return end
  local target = idx + direction
  if target < 1 then target = #entries end
  if target > #entries then target = 1 end
  vim.cmd.edit(vim.fs.joinpath(dir, entries[target]))
end

set('n', ']f', function() sibling_file(1) end, { desc = 'Next sibling file' })
set('n', '[f', function() sibling_file(-1) end, { desc = 'Previous sibling file' })

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
