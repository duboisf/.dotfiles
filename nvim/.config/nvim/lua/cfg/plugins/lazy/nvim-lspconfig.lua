local function config()
  local utils = require 'core.utils'

  local lspconfig = require('lspconfig')

  vim.cmd [[
    sign define DiagnosticSignError text= texthl=DiagnosticSignError
    sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn
    sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo
    sign define DiagnosticSignHint text=󰌵 texthl=DiagnosticSignHint
  ]]

  local function safe_formatting_sync()
    for _, client in pairs(vim.lsp.get_clients()) do
      if client.server_capabilities.documentFormattingProvider then
        vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
        return
      end
    end
  end

  vim.diagnostic.config({
    update_in_insert = true,
    virtual_text = true,
  }, nil)

  -- Setup border for floating windows, here's a description of the
  -- border parameter from the nvim docs (:h nvim_open_win()):
  --   If it is an array, it should have a length of eight or
  --   any divisor of eight. The array will specify the eight
  --   chars building up the border in a clockwise fashion
  --   starting with the top-left corner. As an example, the
  --   double box style could be specified as: >
  --   [ "╔", "═" ,"╗", "║", "╝", "═", "╚", "║" ].
  -- local border = {
  --   { "┌", "FloatBorder" },
  --   { "─", "FloatBorder" },
  --   { "┐", "FloatBorder" },
  --   { "🭲", "FloatBorder" },
  --   { "┘", "FloatBorder" },
  --   { "─", "FloatBorder" },
  --   { "└", "FloatBorder" },
  --   { "🭲", "FloatBorder" }
  -- }

  vim.o.winborder = 'rounded'

  -- Fix grey background in floating windows
  vim.cmd [[ hi! link NormalFloat Normal ]]

  -- -- Add border to hover window
  -- local original_hover = vim.lsp.buf.hover
  -- ---@diagnostic disable-next-line: duplicate-set-field
  -- vim.lsp.buf.hover = function(opts)
  --   opts = vim.tbl_deep_extend('force', { border = border }, opts or {})
  --   original_hover(opts)
  -- end

  ---Setup autocmds for buffer
  ---@param client vim.lsp.Client
  ---@param bufnr number
  local function setup_autocmds(client, bufnr)
    local autocmd, group_id = utils.autogroup('duboisf.lsp.buffer', false)
    local opts = { buffer = bufnr }

    local server_capabilities = client.server_capabilities

    if server_capabilities then
      if server_capabilities.codeLensProvider then
        autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, nil, vim.lsp.codelens.refresh, 'Refresh codelens', opts)
      end

      if server_capabilities.documentHighlightProvider then
        autocmd({ 'CursorHold' }, nil, vim.lsp.buf.document_highlight,
          'Highlight symbol under the cursor throughout document', opts)
        autocmd({ 'CursorMoved' }, nil, vim.lsp.buf.clear_references, 'Clear highlighted lsp symbol', opts)
      end
    end


    local function clear_buffer_autocmds()
      vim.api.nvim_clear_autocmds { buffer = bufnr, group = group_id }
    end

    autocmd('BufUnload', nil, clear_buffer_autocmds, 'Delete buffer autocmds to prevent duplicates', opts)
  end

  -- Setup mappings
  local setup_mappings = (function()
    local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })

    ---@param client vim.lsp.Client
    ---@param bufnr number
    return function(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }

      if client:supports_method("textDocument/formatting", bufnr) then
        vim.keymap.set("n", "<Leader>F", function()
          vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
        end, { buffer = bufnr, desc = "[lsp] format" })

        -- format on save
        vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          group = group,
          callback = function()
            vim.lsp.buf.format({
              bufnr = bufnr,
              async = false,
              filter = function(format_client)
                return format_client.name ~= "ts_ls"
              end
            })
          end,
          desc = "[lsp] format on save",
        })
      end

      if client:supports_method("textDocument/rangeFormatting", bufnr) then
        vim.keymap.set("x", "<Leader>F", function()
          vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
        end, { buffer = bufnr, desc = "[lsp] format" })
      end

      local normal_mappings = {
        -- [',s']        = '<cmd>Telescope lsp_document_symbols<CR>',
        -- [',w']        = '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>',
        ['<leader>F'] = safe_formatting_sync,
        -- ['gD']        = '<Cmd>lua vim.lsp.buf.type_definition()<CR>',
        -- ['gd']        = '<Cmd>Telescope lsp_definitions<CR>',
      }

      for lhs, rhs in pairs(normal_mappings) do
        vim.keymap.set('n', lhs, rhs, opts)
      end
    end
  end)()

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  ---@param client vim.lsp.Client
  ---@param bufnr number
  local on_attach = function(client, bufnr)
    setup_autocmds(client, bufnr)
    setup_mappings(client, bufnr)

    -- disable diagnostics for helm templates
    if vim.bo[bufnr].filetype == 'yaml' and string.find(vim.api.nvim_buf_get_name(bufnr), '/templates/') then
      vim.diagnostic.enable(false)
    end

    -- workaround to gopls hl semanticTokens
    -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
    if client.name == "gopls" then
      if not client.server_capabilities.semanticTokensProvider then
        local textDocument = client.config.capabilities.textDocument
        local semanticTokens = textDocument and textDocument.semanticTokens
        if semanticTokens then
          client.server_capabilities.semanticTokensProvider = {
            full = true,
            legend = {
              tokenTypes = semanticTokens.tokenTypes,
              tokenModifiers = semanticTokens.tokenModifiers,
            },
            range = true,
          }
        end
      end
    end
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end

  -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
  local capabilities = require('blink.cmp').get_lsp_capabilities()

  --[[

    LSP server configs

  --]]
  local function setup_lsps()
    lspconfig.bashls.setup { capabilities = capabilities, on_attach = on_attach }
    lspconfig.dockerls.setup { capabilities = capabilities, on_attach = on_attach }
    lspconfig.jsonls.setup {
      capabilities = capabilities,
      settings = {
        json = {
          format = {
            enable = false
          }
        }
      },
      on_attach = on_attach
    }

    lspconfig.pyright.setup({
      ---@param client vim.lsp.Client
      ---@param bufnr number
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        local ns = vim.lsp.diagnostic.get_namespace(client.id)
        vim.diagnostic.config({ virtual_text = true, signs = true, update_in_insert = true }, ns)
      end,
      on_init = function(client)
        local root_dir = client.config.root_dir
        local venv_path = root_dir .. "/.venv"
        if vim.fn.isdirectory(venv_path) == 1 then
          client.config.settings.python.pythonPath = venv_path .. "/bin/python"
        end
      end,
      filetype = { "python" },
      settings = {
        pyright = {
          disableOrganizeImports = true,
        },
        python = {
          analysis = {
            typeCheckingMode = "off",
            diagnosticMode = "workspace",
            typeCheckingBehavior = "strict",
            reportMissingType = true,
            reportUnusedImport = false,
            reportUnusedVariable = false,
          },
        },
      },
    })

    lspconfig.ruff.setup {
      capabilities = capabilities,
      on_attach = on_attach,
      init_options = {
        settings = {
          showSyntaxErrors = true,
          lint = {
            extendSelect = { "I" }
          }
        }
      }
    }

    lspconfig.ruby_lsp.setup { capabilities = capabilities, on_attach = on_attach, init_options = {
      formatter = 'standard',
      linters = { 'standard' },
    } }
    lspconfig.rnix.setup { capabilities = capabilities, on_attach = on_attach }
    lspconfig.nushell.setup { capabilities = capabilities, on_attach = on_attach }
    lspconfig.rust_analyzer.setup { capabilities = capabilities, on_attach = on_attach }
    lspconfig.sqlls.setup { capabilities = capabilities, on_attach = on_attach }
    lspconfig.terraformls.setup { capabilities = capabilities, on_attach = on_attach }
    lspconfig.taplo.setup { capabilities = capabilities, on_attach = on_attach }
    lspconfig.ts_ls.setup {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        local ns = vim.lsp.diagnostic.get_namespace(client.id)
        vim.diagnostic.config({
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
        }, ns)
      end,
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
            },
            format = {
              enable = true,
              defaultConfig = {
                indent_style = "space",
                indent_size = "2",
              }
            },
            hint = {
              enable = true,
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
  end

  setup_lsps()
end

return {
  {
    'williamboman/mason.nvim',
    opts = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = true,
    dependencies = {
      'williamboman/mason.nvim',
    }
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      config()
    end,
    dependencies = {
      'nvim-navbuddy',
      'saghen/blink.cmp',
      'williamboman/mason-lspconfig.nvim',
    },
  }
}
