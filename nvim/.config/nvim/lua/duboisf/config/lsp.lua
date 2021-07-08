local lspconfig = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  for _, mode in ipairs({'n', 'i'}) do
    buf_set_keymap(mode, '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  end
  -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  --buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  buf_set_keymap('n', '<leader>l', '<cmd>lua vim.lsp.codelens.run()<CR>', opts)

  vim.api.nvim_exec("autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()", false)
  -- vim.api.nvim_exec("autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()", false)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    virtual_text = {
      spacing = 2,
      severity_limit = "Hint",
    },
    signs = true,
    update_in_insert = false,
  }
)

-- vim.fn.sign_define('lspdiagnosticssignerror', { text = "", texthl = "lspdiagnosticsdefaulterror" })
-- vim.fn.sign_define('lspdiagnosticssignwarning', { text = "", texthl = "lspdiagnosticsdefaultwarning" })
-- vim.fn.sign_define('lspdiagnosticssigninformation', { text = "", texthl = "lspdiagnosticsdefaultinformation" })
-- vim.fn.sign_define('lspdiagnosticssignhint', { text = "", texthl = "lspdiagnosticsdefaulthint" })

-- use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- nvim_lsp.gopls.setup {
--   on_attach = on_attach,
--   init_options = {
--     analyses = {
--         printf = false
--     },
--     codelenses = {
--         test = true
--     }
--   },
--   flags = {
--     debounce_text_changes = 150,
--   }
-- }
lspconfig.gopls.setup{
  on_attach = on_attach,
  -- capabilities = capabilities,
  flags = {
    allow_incremental_sync = true
  },
  init_options = {
    staticcheck = false,
    allExperiments = false,
    usePlaceholders = false,
    analyses = {
      nilness = true,
      unusedparams = true,
    },
    codelenses = {
      gc_details = true,
      test = true,
      generate = true,
      regenerate_cgo = true,
      tidy = true,
      upgrade_dependency = true,
      vendor = true,
    },
  },
}

local configs = require 'lspconfig/configs'

if not lspconfig.golangcilsp then
    configs.golangcilsp = {
        default_config = {
            cmd = {'golangci-lint-langserver'},
            root_dir = lspconfig.util.root_pattern('.git', 'go.mod'),
            init_options = {
                    command = { "golangci-lint", "run", "--out-format", "json" };
            }
        };
    }
end

lspconfig.golangcilsp.setup {
    filetypes = {'go'}
}
