local function config()
  local cmp = require 'cmp'
  local lspkind = require 'lspkind'
  local types = require 'cmp.types'

  -- local has_words_before = function()
  --   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  --   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  -- end

  local all_buffers_source = {
    name = 'buffer',
    option = {
      get_bufnrs = function()
        return vim.api.nvim_list_bufs()
      end
    }
  }

  cmp.setup({
    completion = {
      completeopt = "menu,menuone,noselect",
    },
    formatting = {
      fields = { 'abbr', 'kind', 'menu' },
      format = function(entry, vim_item)
        local format = lspkind.cmp_format({
          mode = 'symbol', -- show only symbol annotations
          maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
          menu = ({
            buffer = "[Buffer]",
            dictionary = "[Dict]",
            luasnip = "✂️ ",
            path = "[Path]",
            emoji = "",
            nvim_lsp = "[LSP]",
          })
        })
        local item = format(entry, vim_item)
        item.dup = 0
        return item
      end
    },
    snippet = {
      expand = function(args) require('luasnip').lsp_expand(args.body) end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping(function()
        if cmp.visible() then
          cmp.confirm({ select = true })
        else
          cmp.complete()
        end
      end, { "i", "s" }),
      ['<C-j>'] = cmp.mapping(function(fallback)
        local ls = require("luasnip")
        if ls.expand_or_locally_jumpable() then
          ls.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ['<C-k>'] = cmp.mapping(function(fallback)
        local ls = require("luasnip")
        if ls.jumpable(-1) then
          ls.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
      -- mapping to show completion from all words from all buffers if completion menu isn't open
      ['<C-n>'] = cmp.mapping(function()
        if cmp.visible() then
          cmp.select_next_item()
        else
          cmp.complete({
            config = {
              sources = {
                all_buffers_source,
              }
            }
          })
        end
      end),
      ['<C-x><C-n>'] = cmp.mapping.complete({
        config = {
          sources = {
            all_buffers_source,
          }
        }
      }),
      ['<M-e>'] = cmp.mapping(function()
        cmp.complete({
          config = {
            sources = { { name = 'emoji' } }
          }
        })
      end),
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end)
    }),
    preselect = cmp.PreselectMode.None,
    sources = cmp.config.sources({
      { name = 'luasnip' },
      { name = 'nvim_lsp' },
      { name = 'path' },
    }),
  })

  local comparators = (function()
    local function is_lsp_source(entry)
      return entry.source.name == 'nvim_lsp'
    end

    -- When proposed by gopls, I want the 'if err != nil { return ... }~' lsp snippet to appear first
    local function is_iferr_snippet(entry)
      return is_lsp_source(entry)
          and entry:get_kind() == types.lsp.CompletionItemKind.Keyword
          and entry:get_completion_item().label:find("err != nil.*~$")
    end

    return {
      gopls_iferr_priority = function(entry1, entry2)
        if is_iferr_snippet(entry1) then
          return true
        elseif is_iferr_snippet(entry2) then
          return false
        end
      end
    }
  end)()

  --
  -- Setup different sources and comparators for golang
  --
  do
    cmp.setup.filetype('go', {
      sorting = {
        -- priority_weight = 2,
        comparators = {
          comparators.gopls_iferr_priority,
          -- cmp.config.compare.kind,
          -- compare_locality uses distance-based sorting, taken from cmp-buffer README.
          -- It can also improve the accuracy of LSP suggestions too.
          function(...) return require 'cmp_buffer':compare_locality(...) end,
        }
      },
      sources = cmp.config.sources({
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
      }),
    })
  end

  cmp.setup.filetype({ 'gitcommit', 'markdown' }, {
    sources = {
      { name = 'buffer' },
      { name = 'emoji', option = { insert = true } },
      { name = 'luasnip' },
    }
  })

  cmp.setup.filetype({ 'lua' }, {
    sources = cmp.config.sources({
      { name = 'nvim_lua' },
      { name = 'luasnip' },
      { name = 'path' },
    }),
  })

  cmp.setup.filetype({ 'rego' }, {
    sources = cmp.config.sources({
      all_buffers_source,
      { name = 'luasnip' },
      { name = 'path' },
    }),
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    formatting = {
      format = function(_, vim_item)
        -- remove duplicates
        vim_item.dup = 0
        return vim_item
      end
    },
    mapping = cmp.mapping.preset.cmdline({
      ['<C-f>'] = {
        c = function(fallback)
          cmp.abort()
          fallback()
        end
      },
    }),
    sources = cmp.config.sources({
      { name = 'path' },
      { name = 'cmdline' }
    })
  })

  local function fix_highlights()
    local c = vim.cmd
    -- gray
    c 'highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080'
    -- blue
    c 'highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6'
    c 'highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6'
    -- light blue
    c 'highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE'
    c 'highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE'
    c 'highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE'
    -- pink
    c 'highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0'
    c 'highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0'
    -- front
    c 'highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4'
    c 'highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4'
    c 'highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4'
  end

  local group = vim.api.nvim_create_augroup('cfg#plugins#cmp', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    pattern = "*",
    callback = fix_highlights,
  })

  fix_highlights()

  -- Insert `(` after select function or method item
  -- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  -- cmp.event:on(
  --   'confirm_done',
  --   cmp_autopairs.on_confirm_done()
  -- )

  --cmp.event:on(
  --  'confirm_done',
  --  cmp_autopairs.on_confirm_done({
  --    filetypes = {
  --      -- "*" is a alias to all filetypes
  --      ["*"] = {
  --        ["("] = {
  --          kind = {
  --            cmp.lsp.CompletionItemKind.Function,
  --            cmp.lsp.CompletionItemKind.Method,
  --          },
  --          handler = handlers["*"]
  --        }
  --      },
  --      lua = {
  --        ["("] = {
  --          kind = {
  --            cmp.lsp.CompletionItemKind.Function,
  --            cmp.lsp.CompletionItemKind.Method
  --          },
  --          ---@param char string
  --          ---@param item item completion
  --          ---@param bufnr buffer number
  --          handler = function(char, item, bufnr)
  --            -- Your handler function. Inpect with print(vim.inspect{char, item, bufnr})
  --          end
  --        }
  --      },
  --      -- Disable for tex
  --      tex = false
  --    }
  --  })
  --)
end

return {
  {
    'hrsh7th/nvim-cmp',
    config = config,
    dependencies = {
      -- add vscode-line pictograms in completion popup
      'onsails/lspkind.nvim',
      -- completion suggestions from language server
      'hrsh7th/cmp-nvim-lsp',
      'nvim-lua/plenary.nvim',
    },
  },
  -- complete words from other buffers
  'hrsh7th/cmp-buffer',
  -- completion when in nvim commandline
  'hrsh7th/cmp-cmdline',
  -- complete words from the dictionary
  'uga-rosa/cmp-dictionary',
  -- complete emojis like :tada:
  'hrsh7th/cmp-emoji',
  -- completion for filesystem paths
  'hrsh7th/cmp-path',
  -- completion for luasnip snippets
  'saadparwaiz1/cmp_luasnip',
  -- completion for neovim lua api
  'hrsh7th/cmp-nvim-lua'
}
