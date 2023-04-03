return {
  'ray-x/go.nvim',
  config = function()
    local go = require 'go'
    local alternate = require 'go.alternate'
    go.setup {
      -- Make sure that the coverage signs always appear at the left most position
      sign_priority = 0,
    }
    vim.keymap.set('n', '<C-6>', function() alternate.switch(true, '') end)
  end,
  ft = 'go',
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'ray-x/guihua.lua',
  },
}
