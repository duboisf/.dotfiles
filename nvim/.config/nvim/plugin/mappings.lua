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

set('n', '<A-t>', require('core.utils').inspectTree,
  { silent = true, desc = 'Calls :InspectTree but keeps cursor in place' })

-- In a terminal buffer, return to normal mode by pressing Esc
set('t', '<Esc>', [[<C-\><C-n>]], { silent = true })

-- in insert mode, make ctrl-e jump to the end of the line, staying in insert mode
set('i', '<silent><C-e>', '<C-O>$', { silent = true })
