local Hydra = require('hydra')

Hydra({
  name = 'Side scroll',
  mode = 'n',
  body = 'z',
  heads = {
    { 'h', '5zh' },
    { 'l', '5zl', { desc = '←/→' } },
    { 'H', 'zH' },
    { 'L', 'zL', { desc = 'half screen ←/→' } },
  },
})

Hydra({
  name = '🌳 Move',
  config = {
    invoke_on_body = true,
  },
  mode = { 'n' },
  body = 'gm',
  heads = {
    { 'j', ":lua require'nvim-treesitter.textobjects.move'.goto_next_start({'@function.outer','@class.outer'})<CR>",
      { desc = '→', silent = true } },
    { 'h', ":lua require'nvim-treesitter.textobjects.move'.goto_next_end({'@function.outer','@class.outer'})<CR>",
      { desc = '→', silent = true } },
    { 'k', ":lua require'nvim-treesitter.textobjects.move'.goto_previous_start({'@function.outer','@class.outer'})<CR>",
      { desc = '←', silent = true } },
    { 'l', ":lua require'nvim-treesitter.textobjects.move'.goto_previous_end({'@function.outer','@class.outer'})<CR>",
      { desc = '←', silent = true } },
    { '<C-c>', '<Esc>', { exit = true } },
    { '<Esc>', '<Esc>', { exit = true } },
  }
})

Hydra {
  name = '🌳 param swapper ⇄',
  config = {
    invoke_on_body = true,
  },
  body = '<leader>p',
  mode = { 'n' },
  heads = {
    { 'l', ":lua require'nvim-treesitter.textobjects.swap'.swap_next('@parameter.inner')<CR>",
      { desc = 'Swap right', silent = true } },
    { 'h', ":lua require'nvim-treesitter.textobjects.swap'.swap_previous('@parameter.inner')<CR>",
      { desc = 'Swap left', silent = true } },
  },
}
