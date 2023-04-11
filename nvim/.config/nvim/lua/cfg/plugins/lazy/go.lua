return {
  'ray-x/go.nvim',
  config = function()
    local go = require 'go'
    local alternate = require 'go.alternate'
    go.setup {
      lsp_inlay_hints = {
        enabled = true,
        only_current_line = true,
      },
      -- Make sure that the coverage signs always appear at the left most position
      sign_priority = 0,
    }
    vim.cmd [[highlight link goCoverageCovered Function]]
    vim.keymap.set('n', '<C-6>', function() alternate.switch(true, '') end)
  end,
  ft = 'go',
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'ray-x/guihua.lua',
  },
}
