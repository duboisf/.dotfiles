-- This needs to be called first
require('nvim-lsp-installer').setup {
  -- install language servers that are configured with lspconfig automatically
  automatic_installation = true,
}

local lspconfig = require('lspconfig')

vim.cmd [[
  sign define DiagnosticSignError text= texthl=DiagnosticSignError
  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn
  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo
  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint
]]

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  --Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  require('aerial').on_attach(client, bufnr)

  -- Mappings.
  local opts = { noremap = true, silent = true, buffer = bufnr }

  local normal_mappings = {}
  local nm              = normal_mappings
  nm['gD']              = '<Cmd>lua vim.lsp.buf.declaration()<CR>'
  -- nm['gd']        = '<Cmd>lua vim.lsp.buf.definition()<CR>'
  nm['gd']              = '<Cmd>Telescope lsp_definitions<CR>'
  nm['K']               = '<Cmd>lua vim.lsp.buf.hover()<CR>'
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
    vim.keymap.set('n', lhs, rhs, opts)
  end

  for _, mode in ipairs({ 'n', 'i' }) do
    vim.keymap.set(mode, '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  end

  local capabilities = client.server_capabilities

  if capabilities.codeLensProvider then
    vim.api.nvim_exec("autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()", false)
    vim.api.nvim_command [[autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()]]
  end

  if capabilities.documentHighlightProvider then
    vim.cmd [[ autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight() ]]
    vim.cmd [[ autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight() ]]
    vim.cmd [[ autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references() ]]
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
})


lspconfig.tsserver.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.terraformls.setup { capabilities = capabilities, on_attach = on_attach }
-- lspconfig.solargraph.setup { capabilities = capabilities, on_attach = on_attach }
-- lspconfig.pyright.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.jsonls.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.dockerls.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.bashls.setup { capabilities = capabilities, on_attach = on_attach }

do
  -- local runtime_path = vim.split(package.path, ';')
  local runtime_path = {}
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')
  lspconfig.sumneko_lua.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      Lua = {
        diagnostics = {
          globals = {
            'vim',
          },
          -- disable = {'lowercase-global'},
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
          maxPreload = 1000,
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

do
  local util = require('lspconfig/util')
  local lastRootPath = nil
  local gopath = os.getenv("GOPATH")
  if gopath == nil then
    local ok = false
    ok, gopath = pcall(vim.fn.system, { 'go', 'env', 'GOPATH' })
    if ok then
      gopath = vim.trim(gopath)
    else
      gopath = ""
    end
  end
  local gopathmod = gopath .. '/pkg/mod'
  lspconfig.gopls.setup {
    on_attach = on_attach,
    capabilities = (function()
      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      local caps = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
      -- caps.textDocument.completion.completionItem.snippetSupport = true
      -- caps.textDocument.completion.completionItem.resolveSupport = {
      --   properties = {
      --     'documentation',
      --     'detail',
      --     'additionalTextEdits',
      --   }
      -- }
      return caps
    end)(),
    -- flags = {
    --   allow_incremental_sync = true
    -- },
    init_options = {
      allExperiments = true,
      -- allowImplicitNetworkAccess = true,
      -- templateExtensions = { "yaml" },
      -- staticcheck = false,
      usePlaceholders = true,
      -- analyses = {
      --   nilness = true,
      --   unusedparams = true,
      -- },
      -- codelenses = {
      --   gc_details = false,
      --   test = true,
      --   generate = true,
      --   regenerate_cgo = true,
      --   tidy = true,
      --   upgrade_dependency = true,
      --   vendor = false,
      -- },
    },
    -- don't spawn a new gopls instance if we are jumping to definitions of
    -- functions in dependencies that are in the $GOPATH. Without this, a new
    -- gopls instance will spawn and the root dir will be the $GOPATH and it
    -- can't jump to symbols because it can't find a go.mod.
    root_dir = function(fname)
      local fullpath = vim.fn.expand(fname, ':p')
      if string.find(fullpath, gopathmod) and lastRootPath ~= nil then
        return lastRootPath
      end
      lastRootPath = util.root_pattern("go.mod", ".git")(fname)
      return lastRootPath
    end,
  }
end

local function safe_formatting_sync()
  local id, client = next(vim.lsp.buf_get_clients())
  if id ~= nil and client.server_capabilities.documentFormattingProvider then
    if vim.lsp.buf.format then
      vim.lsp.buf.format(nil, 1000)
    else
      vim.lsp.buf.formatting_sync(nil, 1000)
    end
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
