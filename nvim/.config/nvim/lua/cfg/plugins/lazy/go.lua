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

    local function mappings()
      local set = vim.keymap.set
      set('n', '<C-6>', function() alternate.switch(true, '') end, { buffer = true })
      set('n', 'gtt', ':GoTestFile<CR>', { buffer = true, silent = true })
      set('n', 'gtc', ':GoCoverage -p<CR>', { buffer = true, silent = true })
    end

    local autocmd = require('core.utils').autogroup('cfg#plugin#lazy#go', true)
    autocmd('FileType', 'go', mappings, 'Setup mappings for working in go')
  end,
  ft = 'go',
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'ray-x/guihua.lua',
  },
}
