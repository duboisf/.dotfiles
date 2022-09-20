local utils = require 'core.utils'

local lspconfig = require('lspconfig')

vim.cmd [[
  sign define DiagnosticSignError text= texthl=DiagnosticSignError
  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn
  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo
  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint
]]

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

vim.diagnostic.config {
  underline = {
    severity = vim.diagnostic.severity.WARN,
  },
  virtual_text = {
    spacing = 2,
    severity = vim.diagnostic.severity.WARN,
  },
  signs = true,
  update_in_insert = false,
}

-- Setup floating preview border
local function setup_highlights()
  vim.cmd [[
    highlight NormalFloat guibg=#1f2335
    highlight FloatBorder guifg=white guibg=#1f2335
  ]]
end

local border = {
      {"🭽", "FloatBorder"},
      {"▔", "FloatBorder"},
      {"🭾", "FloatBorder"},
      {"▕", "FloatBorder"},
      {"🭿", "FloatBorder"},
      {"▁", "FloatBorder"},
      {"🭼", "FloatBorder"},
      {"▏", "FloatBorder"},
}

local orig_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_open_floating_preview(contents, syntax, opts, ...)
end

-- Setup autocmds for buffer
local function setup_autocmds(client, bufnr)
  local autocmd, group_id = utils.autogroup('cfg#plugins#lsp#on_attach', false)
  local opts = { buffer = bufnr }

  local server_capabilities = client.server_capabilities

  if server_capabilities.codeLensProvider then
    autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, nil, vim.lsp.codelens.refresh, 'Refresh codelens', opts)
  end

  if server_capabilities.documentHighlightProvider then
    autocmd({ 'CursorHold' }, nil, vim.lsp.buf.document_highlight,
      'Highlight symbol under the cursor throughout document', opts)
    autocmd({ 'CursorMoved' }, nil, vim.lsp.buf.clear_references, 'Clear highlighted lsp symbol', opts)
  end

  local function clear_buffer_autocmds()
    vim.api.nvim_clear_autocmds { buffer = bufnr, group = group_id }
  end

  autocmd('BufUnload', nil, clear_buffer_autocmds, 'Delete buffer autocmds to prevent duplicates', opts)
end

local autocmd = utils.autogroup('cfg#plugins#lsp', true)
autocmd('ColorScheme', nil, setup_highlights, 'Setup LSP highlights')
setup_highlights()

-- Setup mappings
local function setup_mappings(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  local normal_mappings = {
    [',s']         = '<cmd>Telescope lsp_document_symbols<CR>',
    [',w']         = '<cmd>Telescope lsp_workspace_symbols<CR>',
    ['<leader>F']  = safe_formatting_sync,
    ['<leader>cl'] = '<cmd>lua vim.lsp.codelens.run()<CR>',
    ['<leader>ca'] = '<cmd>lua vim.lsp.buf.code_action()<CR>',
    ['<leader>d']  = '<cmd>lua vim.diagnostic.open_float()<CR>',
    ['<leader>rn'] = '<cmd>lua vim.lsp.buf.rename()<CR>',
    ['K']          = '<Cmd>lua vim.lsp.buf.hover()<CR>',
    ['[d']         = '<cmd>lua vim.diagnostic.goto_prev()<CR>',
    [']d']         = '<cmd>lua vim.diagnostic.goto_next()<CR>',
    ['gD']         = '<Cmd>lua vim.lsp.buf.type_definition()<CR>',
    ['gd']         = '<Cmd>Telescope lsp_definitions<CR>',
    ['gi']         = '<cmd>Telescope lsp_implementations<CR>',
    ['gr']         = '<cmd>Telescope lsp_references<CR>',
  }

  for lhs, rhs in pairs(normal_mappings) do
    vim.keymap.set('n', lhs, rhs, opts)
  end

  for _, mode in ipairs({ 'i' }) do
    -- TODO: check if the language server supports signature help before adding this mapping
    vim.keymap.set(mode, '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  end
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local ok, aerial = pcall(require, 'aerial')
  if ok then
    aerial.on_attach(client, bufnr)
  end

  setup_autocmds(client, bufnr)
  setup_mappings(bufnr)

  -- disable diagnostics for helm templates
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
    severity = vim.diagnostic.severity.WARN,
  },
  signs = true,
  update_in_insert = false,
})


local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

--[[

  LSP server configs

--]]

-- lspconfig.pyright.setup { capabilities = capabilities, on_attach = on_attach }
-- lspconfig.solargraph.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.bashls.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.dockerls.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.jsonls.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.pylsp.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.terraformls.setup { capabilities = capabilities, on_attach = on_attach }
lspconfig.tsserver.setup {
  capabilities = capabilities,
  handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
      underline = {
        severity = {
          -- don't know why but with typescript language server I need to use this min key to get it to work, same for virtual_text
          min = vim.diagnostic.severity.INFO,
        },
      },
      virtual_text = {
        spacing = 2,
        -- severity_limit = "Hint",
        severity = {
          min = vim.diagnostic.severity.WARN,
        },
      },
      signs = true,
      update_in_insert = false,
    }),
  },
  on_attach = on_attach
}

do
  lspconfig.sumneko_lua.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      -- Ref: https://github.com/sumneko/lua-language-server/wiki/Settings
      Lua = {
        completion = {
          callSnippet = 'Both',
          displayContext = 1,
        },
        diagnostics = {
          globals = {
            'vim',
          },
          libraryFiles = 'Disable',
        },
        hint = {
          setType = true,
        },
        runtime = {
          -- prevent suggesting paths like '.config.nvim.lua.core.utils' when we really want 'core.utils'
          path = { 'lua/?.lua', 'lua/?/init.lua' },
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
  schemas["https://json.schemastore.org/github-workflow"] = "/.github/workflows/*.yml"
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
