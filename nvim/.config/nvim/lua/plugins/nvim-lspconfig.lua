local function config()
  local utils = require 'core.utils'

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

  -- local orig_buf_request_all = vim.lsp.buf_request_all
  -- ---@diagnostic disable-next-line: duplicate-set-field
  -- vim.lsp.buf_request_all = function(bufnr, method, params, handler)
  --   return orig_buf_request_all(bufnr, method, params, function(results, context, cfg)
  --     local transformed_results = {} --- @type table<integer,lsp.Hover>
  --     for _, res in pairs(results) do
  --       local err, result = res.err, res.result
  --       if not err then
  --         if result and type(result.contents) == 'table' and result.contents.kind == 'markdown' then
  --           -- Strip backslash escapes from plaintext
  --           if result.contents.value then
  --             -- result.contents.value = result.contents.value:gsub('\\([%.%[%]%(%)%*])', '%1')
  --             result.contents.value = result.contents.value:gsub('\\([%.%(%)])', '%1')
  --             result.contents.value = result.contents.value:gsub('\\%[(.-)%]', '`%1`')
  --           end
  --         end
  --       end
  --       table.insert(transformed_results, res)
  --     end
  --     return handler(transformed_results, context, cfg)
  --   end)
  -- end

  vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = {
      current_line = true,
    },
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
    autocmd('LspDetach', nil, clear_buffer_autocmds, 'Delete buffer autocmds when lsp client detaches', opts)
  end

  -- Setup mappings
  local setup_mappings = (function()
    local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })

    ---@param client vim.lsp.Client
    ---@param bufnr number
    return function(client, bufnr)
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

        if client.name == 'lua_ls' then
          vim.api.nvim_create_autocmd("BufWritePost", {
            buffer = bufnr,
            group = group,
            desc = "Fix diagnostics disapearing after formatting file with lua_ls",
            callback = function()
              vim.diagnostic.enable(true)
            end

          })
        end
      end

      if client:supports_method("textDocument/rangeFormatting", bufnr) then
        vim.keymap.set("x", "<Leader>F", function()
          vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
        end, { buffer = bufnr, desc = "[lsp] format" })
      end

      local function set(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
      end

      set('grl', function() vim.lsp.codelens.run() end, '[lsp] vim.lsp.codelens.run()')
      set('<leader>F', safe_formatting_sync, '[lsp] format')
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
    vim.lsp.config('*', {
      capabilities = capabilities,
      on_attach = on_attach,
    })
    local lspconfig = vim.lsp.config
    lspconfig.jsonls = {
      settings = {
        json = {
          format = {
            enable = false
          }
        }
      },
    }

    -- lspconfig.pyright = {
    --   ---@param client vim.lsp.Client
    --   ---@param bufnr number
    --   on_attach = function(client, bufnr)
    --     on_attach(client, bufnr)
    --     local ns = vim.lsp.diagnostic.get_namespace(client.id)
    --     vim.diagnostic.config({ virtual_text = true, signs = true, update_in_insert = false }, ns)
    --   end,
    --   on_init = function(client)
    --     local root_dir = client.config.root_dir
    --     if not root_dir then
    --       return
    --     end
    --     local venv_path = root_dir .. "/.venv"
    --     if vim.fn.isdirectory(venv_path) == 1 then
    --       client.config.settings.python.pythonPath = venv_path .. "/bin/python"
    --     end
    --   end,
    --   filetype = { "python" },
    --   settings = {
    --     pyright = {
    --       disableOrganizeImports = true,
    --     },
    --     python = {
    --       analysis = {
    --         typeCheckingMode = "on",
    --         diagnosticMode = "workspace",
    --         typeCheckingBehavior = "strict",
    --         reportMissingType = true,
    --         reportUnusedImport = false,
    --         reportUnusedVariable = false,
    --       },
    --     },
    --   },
    -- }

    lspconfig.ruff = {
      init_options = {
        settings = {
          showSyntaxErrors = true,
          lint = {
            extendSelect = { "I" }
          }
        }
      }
    }

    lspconfig.ruby_lsp = {
      init_options = {
        formatter = 'standard',
        linters = { 'standard' },
      }
    }
    lspconfig.ts_ls = {
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
      lspconfig.lua_ls = {
        settings = {
          -- Ref: https://github.com/sumneko/lua-language-server/wiki/Settings
          Lua = {
            completion = {
              callSnippet = 'Both',
              displayContext = 4,
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
      lspconfig.yamlls = {
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow"] = "/.github/workflows/*.yml",
            },
            schemaDownload = { enable = true },
            trace = {
              server = "verbose"
            },
            validate = true,
          }
        }
      }
      -- Use volta to run yamlls with node 22.
      -- This is needed because if there is a project with an old (volta) pinned node version
      -- then yamlls fails to start.
      local cmd = lspconfig.yamlls.cmd
      ---@cast cmd string[]
      table.insert(cmd, 1, "--node=22")
      table.insert(cmd, 1, "run")
      table.insert(cmd, 1, "volta")
    end

    do
      -- local util = require('lspconfig/util')
      -- local lastRootPath = nil
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
      -- local gopathmod = gopath .. '/pkg/mod'
      lspconfig.gopls = {
        init_options = {
          -- allExperiments = true,
          -- allowImplicitNetworkAccess = true,
          -- templateExtensions = { "yaml" },
          staticcheck = true,
          usePlaceholders = false, -- don't add parameter placeholders when completing a function
          analyses = {
            nilness = true,
            unusedparams = true,
            -- at least one file in a package should have a package comment
            ST1000 = false,
            -- someId should be someID
            ST1003 = false,
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
            ignoredError = true,
            parameterNames = false,
            rangeVariableTypes = false,
          },
          semanticTokens = true,
        },
        -- don't spawn a new gopls instance if we are jumping to definitions of
        -- functions in dependencies that are in the $GOPATH. Without this, a new
        -- gopls instance will spawn and the root dir will be the $GOPATH and it
        -- can't jump to symbols because it can't find a go.mod.
        --   root_dir = function(fname)
        --     if string.find(fname, gopathmod) and lastRootPath ~= nil then
        --       return lastRootPath
        --     end
        --     lastRootPath = util.root_pattern("go.mod", ".git")(fname)
        --     return lastRootPath
        --   end,
      }
    end
  end

  setup_lsps()

  -- Wrap hover handler to strip markdown escape sequences after setup
  -- vim.defer_fn(function()
  --   local original_hover = vim.lsp.handlers['textDocument/hover']
  --   vim.lsp.handlers['textDocument/hover'] = function(err, result, ctx, cfg)
  --     if result and result.contents then
  --       if type(result.contents) == 'table' and result.contents.value then
  --         -- Strip backslash escapes from markdown
  --         result.contents.value = result.contents.value:gsub('\\([%.%[%]%(%)%*])', '%1')
  --       elseif type(result.contents) == 'string' then
  --         result.contents = result.contents:gsub('\\([%.%[%]%(%)%*])', '%1')
  --       end
  --     end
  --     return original_hover(err, result, ctx, cfg)
  --   end
  -- end, 0)
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
      'saghen/blink.cmp',
      'williamboman/mason-lspconfig.nvim',
    },
  }
}
