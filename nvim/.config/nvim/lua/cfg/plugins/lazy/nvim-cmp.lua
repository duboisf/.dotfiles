local utils = require 'core.utils'

local copilot = {}

function copilot.has_suggestion()
  if not utils.has_network() then
    return false
  end
  return require('copilot.suggestion').is_visible()
end

function copilot.accept_word()
  return require('copilot.suggestion').accept_word()
end

function copilot.accept()
  return require('copilot.suggestion').accept()
end

local function config()
  local cmp = require 'cmp'

  local all_buffers_source = {
    name = 'buffer',
    option = {
      get_bufnrs = function()
        return vim.api.nvim_list_bufs()
      end
    }
  }

  local KindIcons = {
    Text = '',
    Method = '󰆧',
    Function = '󰊕',
    Constructor = '',
    Field = '',
    Variable = '󰀫',
    Class = '',
    Interface = '',
    Module = '',
    Property = '',
    Unit = '󰑭',
    Value = '󰎠',
    Enum = '',
    Keyword = '󰌋',
    Snippet = '',
    Color = '󰏘',
    File = '󰈙',
    Reference = '',
    Folder = '󰉋',
    EnumMember = '',
    Constant = '󰏿',
    Struct = '',
    Event = '',
    Operator = '',
    TypeParameter = '',
    User = '',
    Team = '',
  }

  local MenuIcons = {
    buffer = "󰘙",
    dictionary = "",
    emoji = "",
    luasnip = "",
    nvim_lsp = "",
    nvim_lua = "󰢱",
    path = "",
    gh_users = "",
  }

  cmp.setup({
    completion = {
      autocomplete = {
        cmp.TriggerEvent.InsertEnter,
        cmp.TriggerEvent.TextChanged,
      },
      completeopt = "menu,menuone,noselect",
    },
    formatting = {
      format = function(entry, vim_item)
        vim_item.kind = KindIcons[vim_item.kind] or vim_item.kind)
        vim_item.menu = MenuIcons[entry.source.name] or entry.source.name
        return vim_item
      end,
      expandable_indicator = true,
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
      ['<C-CR>'] = cmp.mapping(function()
        if copilot.has_suggestion() then
          local luasnip = require('luasnip')
          if luasnip.in_snippet() then
            luasnip.unlink_current()
          end
          copilot.accept()
        elseif cmp.visible() then
          cmp.confirm({ select = true })
        else
          cmp.complete()
        end
      end, { "i", "s" }),
      ['<C-l>'] = cmp.mapping(function(fallback)
        local luasnip = require 'luasnip'
        if luasnip.choice_active() then
          luasnip.change_choice(1)
        elseif copilot.has_suggestion() then
          copilot.accept_word()
        else
          fallback()
        end
      end, { "i", "s" }),
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
              sources = { all_buffers_source }
            }
          })
        end
      end),
      ['<C-x><C-n>'] = cmp.mapping(function()
        if cmp.visible() then
          cmp.close()
        end
        cmp.complete({ config = { sources = { all_buffers_source } } })
      end),
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
    -- preselect = cmp.PreselectMode.None,
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'emoji' },
      { name = 'buffer',   keyword_length = 3 },
      { name = 'gh_users', keyword_length = 3 },
    }),
  })

  local cmdline_mappings = {
    ['<C-n>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
    },
    ['<C-p>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    },
    ['<C-e>'] = {
      c = cmp.mapping.abort(),
    },
    ['<C-y>'] = {
      c = cmp.mapping.confirm({ select = false }),
    }
  }
  cmp.setup.cmdline('/', {
    mapping = cmdline_mappings,
    sources = {
      { name = 'buffer' },
    }
  })

  cmp.setup.cmdline(':', {
    mapping = cmdline_mappings,
    sources = {
      { name = 'cmdline' }
    }
  })
end

return {
  {
    'hrsh7th/nvim-cmp',
    config = config,
    dependencies = {
      -- completion suggestions from language server
      'hrsh7th/cmp-nvim-lsp',
      'nvim-lua/plenary.nvim',
      'L3MON4D3/LuaSnip',
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
  'hrsh7th/cmp-nvim-lua',
  {
    'duboisf/cmp-gh-users',
    opts = {
      log_level = vim.log.levels.WARN,
      filetypes = { 'gitcommit', 'markdown', 'bash' },
    },
    dev = true,
  },
}
