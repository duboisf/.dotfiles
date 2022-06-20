local cmp = require 'cmp'
local lspkind = require 'lspkind'

-- local has_words_before = function()
--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
-- end

vim.o.completeopt = "menuone,noselect"

cmp.setup({
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text', -- show only symbol annotations
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
    expand = function(args)
      require 'luasnip'.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  sorting = {
    priority_weight = 2,
    comparators = {
      -- compare_locality uses distance-based sorting, taken from cmp-buffer README.
      -- It can also improve the accuracy of LSP suggestions too.
      function(...) return require 'cmp_buffer':compare_locality(...) end,
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
      -- cmp.config.compare.locality,
      -- cmp.config.compare.kind,
      -- cmp.config.compare.offset,
      -- cmp.config.compare.exact,
      -- cmp.config.compare.recently_used,
      -- cmp.config.compare.sort_text,
      -- cmp.config.compare.length,
      -- cmp.config.compare.order,
    },
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item()
      else
        cmp.complete()
      end
    end, { "i", "s" }),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
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
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  -- preselect = cmp.PreselectMode.None,
  sources = cmp.config.sources({
    -- sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    -- { name = 'nvim_lsp_signature_help' },
    { name = 'emoji', keyword_length = 4, option = { insert = true } },
    {
      name = 'buffer',
      option = {
        get_bufnrs = function()
          -- get all visible buffers
          local bufs = {}
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              bufs[buf] = true
            end
          end
          return vim.tbl_keys(bufs)
        end
      }
    },
    { name = 'path' },
    -- { name = 'dictionary', keyword_length = 3, max_item_count = 10 },
  })
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

local group = vim.api.nvim_create_augroup('duboisf#config#plugins#cmp', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  pattern = "*",
  callback = function()
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
  end,
})

cmp.event:on('confirm_done', require 'nvim-autopairs.completion.cmp'.on_confirm_done({ map_char = { tex = '' } }))
