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
    end

    local group = vim.api.nvim_create_augroup('cfg#plugin#lazy#go', { clear = true })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'go',
      group = group,
      desc = 'Setup mappings for working in go',
      callback = mappings,
    })
  end,
  ft = 'go',
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'ray-x/guihua.lua',
  },
}
