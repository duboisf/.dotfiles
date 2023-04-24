local function config()
  local utils = require 'core.utils'

  local lspconfig = require('lspconfig')

  vim.cmd [[
    sign define DiagnosticSignError text= texthl=DiagnosticSignError
    sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn
    sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo
    sign define DiagnosticSignHint text= texthl=DiagnosticSignHint
  ]]

  local function safe_formatting_sync()
    local id, client = next(vim.lsp.get_active_clients())
    if id ~= nil and client.server_capabilities.documentFormattingProvider then
      vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
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
      highlight default link LspSignatureActiveParameter Search
    ]]
  end

  local border = {
    { "🭽", "FloatBorder" },
    { "▔",  "FloatBorder" },
    { "🭾", "FloatBorder" },
    { "▕",  "FloatBorder" },
    { "🭿", "FloatBorder" },
    { "▁",  "FloatBorder" },
    { "🭼", "FloatBorder" },
    { "▏",  "FloatBorder" },
  }

  local orig_open_floating_preview = vim.lsp.util.open_floating_preview
  ---@diagnostic disable-next-line: duplicate-set-field
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
  local setup_mappings = (function()
        local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })

        return function(client, bufnr)
          local opts = { noremap = true, silent = true, buffer = bufnr }

          if client.supports_method("textDocument/formatting") then
            vim.keymap.set("n", "<Leader>F", function()
              vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
            end, { buffer = bufnr, desc = "[lsp] format" })

            -- format on save
            -- vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
            -- vim.api.nvim_create_autocmd("BufWritePre", {
            --   buffer = bufnr,
            --   group = group,
            --   callback = function()
            --     vim.lsp.buf.format({ bufnr = bufnr, async = false })
            --   end,
            --   desc = "[lsp] format on save",
            -- })
          end

          if client.supports_method("textDocument/rangeFormatting") then
            vim.keymap.set("x", "<Leader>F", function()
              vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
            end, { buffer = bufnr, desc = "[lsp] format" })
          end

          local normal_mappings = {
            [',s']         = '<cmd>Telescope lsp_document_symbols<CR>',
            [',w']         = '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>',
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
      end)()

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    setup_autocmds(client, bufnr)
    setup_mappings(client, bufnr)
    -- disable diagnostics for helm templates
    if vim.bo[bufnr].filetype == 'yaml' and string.find(vim.api.nvim_buf_get_name(bufnr), '/templates/') then
      vim.diagnostic.disable()
    end
    if client.name == "gopls" then
      -- workaround to hl semanticTokens
      -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
      if not client.server_capabilities.semanticTokensProvider then
        local semantic = client.config.capabilities.textDocument.semanticTokens
        client.server_capabilities.semanticTokensProvider = {
          full = true,
          legend = {
            tokenTypes = semantic.tokenTypes,
            tokenModifiers = semantic.tokenModifiers,
          },
          range = true,
        }
      end
    end
  end

  vim.diagnostic.config({
    underline = true,
    virtual_text = {
      spacing = 2,
      severity_limit = "Hint",
      severity = vim.diagnostic.severity.WARN,
    },
    signs = true,
    update_in_insert = false,
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  --[[

    LSP server configs

  --]]
  lspconfig.bashls.setup { capabilities = capabilities, on_attach = on_attach }
  lspconfig.dockerls.setup { capabilities = capabilities, on_attach = on_attach }
  lspconfig.jsonls.setup { capabilities = capabilities, on_attach = on_attach }
  lspconfig.jdtls.setup { capabilities = capabilities, on_attach = on_attach }
  lspconfig.marksman.setup { capabilities = capabilities, on_attach = on_attach }
  lspconfig.pylsp.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = {
            ignore = {
              'E501',
            }
          }
        }
      }
    }
  }
  lspconfig.sqlls.setup { capabilities = capabilities, on_attach = on_attach }
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
    lspconfig.lua_ls.setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        -- Ref: https://github.com/sumneko/lua-language-server/wiki/Settings
        Lua = {
          completion = {
            callSnippet = 'Replace',
            displayContext = 1,
          },
          diagnostics = {
            globals = {
              'dump',
              'vim',
            },
            libraryFiles = 'Disable',
          },
          format = {
            enable = true,
            defaultConfig = {
              indent_style = "space",
              indent_size = "2",
            }
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
            -- library = vim.api.nvim_get_runtime_file('', true),
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
      capabilities = capabilities,
      init_options = {
        allExperiments = true,
        -- allowImplicitNetworkAccess = true,
        -- templateExtensions = { "yaml" },
        staticcheck = true,
        usePlaceholders = false, -- don't add parameter placeholders when completing a function
        analyses = {
          nilness = true,
          unusedparams = true,
        },
        codelenses = {
          test = true,
          tidy = true,
          upgrade_dependency = true,
        },
        hints = {
          assignVariableTypes = false,
          compositeLiteralFields = false,
          compositeLiteralTypes = false,
          constantValues = false,
          functionTypeParameters = false,
          parameterNames = false,
          rangeVariableTypes = false,
        },
        semanticTokens = true,
      },
      -- don't spawn a new gopls instance if we are jumping to definitions of
      -- functions in dependencies that are in the $GOPATH. Without this, a new
      -- gopls instance will spawn and the root dir will be the $GOPATH and it
      -- can't jump to symbols because it can't find a go.mod.
      root_dir = function(fname)
        if string.find(fname, gopathmod) and lastRootPath ~= nil then
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
end

return {
  'neovim/nvim-lspconfig',
  config = config,
  dependencies = {
    'folke/neodev.nvim',
    'SmiteshP/nvim-navbuddy',
  }
}
