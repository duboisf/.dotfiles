-- This needs to be called first
require('nvim-lsp-installer').setup {}

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

  local normal_mappings = {}
  local nm = normal_mappings
  nm['gD']        = '<Cmd>lua vim.lsp.buf.declaration()<CR>'
  nm['gd']        = '<Cmd>lua vim.lsp.buf.definition()<CR>'
  nm['K']         = '<Cmd>lua vim.lsp.buf.hover()<CR>'
  nm['gi']        = '<cmd>lua vim.lsp.buf.implementation()<CR>'
  nm['<space>D']  = '<cmd>lua vim.lsp.buf.type_definition()<CR>'
  nm['<space>rn'] = '<cmd>lua vim.lsp.buf.rename()<CR>'
  nm['<space>a']  = '<cmd>lua vim.lsp.buf.code_action()<CR>'
  nm['gr']        = '<cmd>Telescope lsp_references<CR>'
  nm['<space>d']  = '<cmd>lua vim.diagnostic.open_float()<CR>'
  nm['[d']        = '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>'
  nm[']d']        = '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>'
  nm['<leader>l'] = '<cmd>lua vim.lsp.codelens.run()<CR>'
  nm['<leader>F'] = '<cmd>lua require"duboisf.config.lsp".safe_formatting_sync()<CR>'

  for lhs, rhs in pairs(normal_mappings) do
    buf_set_keymap('n', lhs, rhs, opts)
  end
  for _, mode in ipairs({'n', 'i'}) do
    buf_set_keymap(mode, '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  end

  if client.resolved_capabilities.code_lens then
    vim.api.nvim_exec("autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()", false)
    vim.api.nvim_command [[autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()]]
  end

  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_command [[autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()]]
    vim.api.nvim_command [[autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()]]
    vim.api.nvim_command [[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]]
  end

  if vim.bo[bufnr].filetype == 'yaml' and string.find(vim.api.nvim_buf_get_name(bufnr), '/templates/') then
    vim.diagnostic.disable()
  end
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

vim.fn.sign_define('LspDiagnosticsSignError', { text = "", texthl = "LspDiagnosticsSignError" })
vim.fn.sign_define('LspDiagnosticsSignWarning', { text = "", texthl = "LspDiagnosticsSignWarning" })
vim.fn.sign_define('LspDiagnosticsSignInformation', { text = "", texthl = "LspDiagnosticsSignInformation" })
vim.fn.sign_define('LspDiagnosticsSignHint', { text = "", texthl = "LspDiagnosticsSignHint" })

lspconfig.tsserver.setup{ on_attach = on_attach }
lspconfig.terraformls.setup{ on_attach = on_attach }
lspconfig.solargraph.setup{ on_attach = on_attach }
lspconfig.pyright.setup{ on_attach = on_attach }
lspconfig.jsonls.setup{ on_attach = on_attach }
lspconfig.dockerls.setup{ on_attach = on_attach }
lspconfig.bashls.setup{ on_attach = on_attach }

do
  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')
  lspconfig.sumneko_lua.setup{
    on_attach = on_attach,
    settings = {
      Lua = {
        diagnostics = {
          globals = {
            'obj', -- argocd lua health check global
            'vim',
          },
          disable = {'lowercase-global'},
        },
        runtime = {
          path = runtime_path,
          version = 'LuaJIT',
        },
        telemetry = {
          enabled = false
        },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file('', true),
          maxPreload = 2000,
        },
      }
    }
  }
end

do
  local schemas = {}
  schemas["http://json.schemastore.org/github-workflow"] = "/.github/workflows/*.yml"
  lspconfig.yamlls.setup{
    on_attach = on_attach,
    settings = {
      yaml = {
        schemas = schemas,
        schemaDownload = { enable = true },
        trace = {
          server = "verbose"
        },
        validate = true,
      }
    }
  }
end

lspconfig.gopls.setup{
  on_attach = on_attach,
  capabilities = (function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = {
        'documentation',
        'detail',
        'additionalTextEdits',
      }
    }
    return capabilities
    end)(),
  flags = {
    allow_incremental_sync = true
  },
  init_options = {
    staticcheck = false,
    allExperiments = true,
    usePlaceholders = true,
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

local function safe_formatting_sync()
  local id, client = next(vim.lsp.buf_get_clients())
  if id ~= nil and client.resolved_capabilities.document_formatting then
    vim.lsp.buf.formatting_sync(nil, 100)
  end
end

-- local configs = require 'lspconfig/configs'

-- if not lspconfig.golangcilsp then
--     configs.golangcilsp = {
--       default_config = {
--         cmd = {'golangci-lint-langserver'},
--         filetypes = {'go'},
--         root_dir = lspconfig.util.root_pattern('.git', 'go.mod'),
--         init_options = {
--           command = { "golangci-lint", "run", "--out-format", "json" }
--         }
--       },
--     }
-- end

-- lspconfig.golangcilsp.setup()

return {
    safe_formatting_sync = safe_formatting_sync
}
