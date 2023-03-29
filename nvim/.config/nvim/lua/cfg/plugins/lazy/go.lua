-- return {
--   'ray-x/go.nvim',
--   config = function()
--     local go = require 'go'
--     local alternate = require 'go.alternate'
--     go.setup {
--       test_efm = true,
--     }
--     vim.keymap.set('n', '<C-6>', function() alternate.switch(true, '') end)
--     local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
--     vim.api.nvim_create_autocmd("BufWritePre", {
--       pattern = "*.go",
--       callback = function()
--         require('go.format').goimport()
--       end,
--       group = format_sync_grp,
--     })
--   end,
--   ft = 'go',
--   dependencies = {
--     'neovim/nvim-lspconfig',
--     'nvim-treesitter/nvim-treesitter',
--     'ray-x/guihua.lua',
--   },
-- }
return {
  'fatih/vim-go',
  config = function()
    local g = vim.g
    g.go_fmt_autosave = 0
    g.go_imports_autosave = 0
    g.go_code_completion_enabled = 0
    g.go_mod_fmt_autosave = 0
  end,
}
