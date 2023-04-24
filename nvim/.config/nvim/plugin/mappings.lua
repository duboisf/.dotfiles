local set = vim.keymap.set

-- Useful map to move over a parenthesis that was injected by the autopairs plugin
set('i', '<C-f>', '<C-o>l')

-- Alt-u changes the cwd of the current tab up one level (to the parent folder)
set('n', '<A-u>', function() vim.cmd.tcd('..') end)

-- Alt-i either opens a popup with the current TreeSitter node or the current
-- highlight group under the cursor
set('n', '<A-i>', require('core.utils').inspect_highlight, {
  silent = true,
  desc = 'Inspect highlight under cursor'
})

set('n', '<leader>v', vim.cmd.Explore)

set('n', '<C-u>', '<C-u>zz')
set('n', '<C-d>', '<C-d>zz')
