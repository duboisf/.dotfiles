local cmp = require 'cmp'
local lspkind = require 'lspkind'
local types = require 'cmp.types'

-- local has_words_before = function()
--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
-- end

vim.o.completeopt = "menuone,noselect"

local all_buffers_source = {
  name = 'buffer',
  option = {
    get_bufnrs = function()
      return vim.api.nvim_list_bufs()
    end
  }
}

cmp.setup({
  formatting = {
    fields = { 'abbr', 'kind', 'menu' },
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      menu = ({
        buffer = "[Buffer]",
        dictionary = "[Dict]",
        luasnip = "[LuaSnip]",
        path = "[Path]",
        emoji = "[Emoji]",
        nvim_lsp = "[LSP]",
      })
    })
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
        cmp.select_next_item()
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
    -- mapping to show completion from all words from all buffers
    ['<C-x><C-n>'] = cmp.mapping.complete({
      config = {
        sources = {
          all_buffers_source,
        }
      }
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end)
  }),
  performance = {
    debounce = 300,
  },
  preselect = cmp.PreselectMode.None,
  sources = cmp.config.sources({
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
    { name = 'emoji', option = { insert = true } },
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
      all_buffers_source,
      { name = 'emoji', option = { insert = true } },
    }),
  })
end

cmp.setup.filetype('gitcommit', {
  sources = { all_buffers_source }
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
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

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
