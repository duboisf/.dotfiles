-- This needs to be called first
require('nvim-lsp-installer').setup {}

local group = vim.api.nvim_create_augroup('cfg#plugins#lsp', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  pattern = "*",
  callback = function()
    local c = vim.cmd
    c 'hi LspReferenceText guibg=#4d1e0a'
    c 'hi LspReferenceRead guibg=#1d1e0a'
    c 'hi LspReferenceWrite guibg=#fd1e0a'
    c 'hi DiagnosticVirtualTextError guifg=Red ctermfg=Red'
    c 'hi DiagnosticVirtualTextWarning guifg=Yellow ctermfg=Yellow'
    c 'hi DiagnosticVirtualTextInformation guifg=White ctermfg=White'
    c 'hi DiagnosticVirtualTextHint guifg=White ctermfg=White'
    c 'hi DiagnosticUnderlineError guifg=Red ctermfg=NONE cterm=undercurl gui=undercurl'
    c 'hi DiagnosticUnderlineWarning guifg=Yellow ctermfg=NONE cterm=underline gui=underline'
    c 'hi DiagnosticUnderlineInformation guifg=NONE ctermfg=NONE cterm=underline gui=underline'
    c 'hi DiagnosticUnderlineHint guifg=Cyan ctermfg=NONE cterm=underline gui=underline'
    c 'hi DiagnosticFloatingError guifg=#E74C3C'
    c 'hi DiagnosticSignError guifg=#E74C3C'
    c 'hi LspCodeLens guifg=Cyan'
  end,
})

local lspconfig = require('lspconfig')

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }

  local normal_mappings = {}
  local nm              = normal_mappings
  nm['gD']              = '<Cmd>lua vim.lsp.buf.declaration()<CR>'
  -- nm['gd']        = '<Cmd>lua vim.lsp.buf.definition()<CR>'
  nm['gd']              = '<Cmd>Telescope lsp_definitions<CR>'
  -- nm['K']               = '<Cmd>lua vim.lsp.buf.hover()<CR>'
  nm['gi']              = '<cmd>lua vim.lsp.buf.implementation()<CR>'
  nm['<space>D']        = '<cmd>lua vim.lsp.buf.type_definition()<CR>'
  nm['<space>rn']       = '<cmd>lua vim.lsp.buf.rename()<CR>'
  nm['<space>a']        = '<cmd>lua vim.lsp.buf.code_action()<CR>'
  nm['gr']              = '<cmd>Telescope lsp_references<CR>'
  nm['<space>d']        = '<cmd>lua vim.diagnostic.open_float()<CR>'
  nm['[d']              = '<cmd>lua vim.diagnostic.goto_prev()<CR>'
  nm[']d']              = '<cmd>lua vim.diagnostic.goto_next()<CR>'
  nm['<leader>l']       = '<cmd>lua vim.lsp.codelens.run()<CR>'
  nm['<leader>F']       = '<cmd>lua require"cfg.plugins.lsp".safe_formatting_sync()<CR>'

  for lhs, rhs in pairs(normal_mappings) do
    buf_set_keymap('n', lhs, rhs, opts)
  end
  -- for _, mode in ipairs({ 'n', 'i' }) do
  --   buf_set_keymap(mode, '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- end

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

lspconfig.tsserver.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.terraformls.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.solargraph.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.pyright.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.jsonls.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.dockerls.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.bashls.setup { capabilities = capabilities, on_attach = on_attach }

do
  -- local runtime_path = vim.split(package.path, ';')
  -- table.insert(runtime_path, 'lua/?.lua')
  -- table.insert(runtime_path, 'lua/?/init.lua')
  lspconfig.sumneko_lua.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      Lua = {
        diagnostics = {
          globals = {
            -- 'obj', -- argocd lua health check global
            'vim',
          },
          -- disable = {'lowercase-global'},
        },
        runtime = {
          -- path = runtime_path,
          version = 'LuaJIT',
        },
        telemetry = {
          enabled = false
        },
        workspace = {
          -- checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file('', true),
          -- maxPreload = 2000,
        },
      }
    }
  }
end

do
  local schemas = {}
  schemas["http://json.schemastore.org/github-workflow"] = "/.github/workflows/*.yml"
  lspconfig.yamlls.setup {
    capabilities = capabilities,
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

lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = (function()
    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    local caps = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
    caps.textDocument.completion.completionItem.snippetSupport = true
    caps.textDocument.completion.completionItem.resolveSupport = {
      properties = {
        'documentation',
        'detail',
        'additionalTextEdits',
      }
    }
    return caps
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
    vim.lsp.buf.formatting_sync(nil, 1000)
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

function _G.signature_help()
  local req = vim.lsp.util.make_position_params(0, 'utf-16')
  req.context = {
    triggerKind = 1,
    isRetrigger = false,
  }
  dump(vim.lsp.buf_get_clients()[1].request_sync('textDocument/signatureHelp', req))
end

return {
  safe_formatting_sync = safe_formatting_sync
}
