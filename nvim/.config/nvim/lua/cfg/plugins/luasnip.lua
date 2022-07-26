local ls = require 'luasnip'
local select_choice = require('luasnip.extras.select_choice')
local types = require 'luasnip.util.types'

local higroup = vim.api.nvim_create_augroup('cfg#plugins#luasnip', { clear = true })

local function setup_highlights()
  vim.cmd [[
      hi LuaSnipChoiceNode guifg=#d65d0e
      hi LuaSnipInsertNode guifg=#fabd2f
    ]]
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = higroup,
  pattern = "*",
  callback = setup_highlights,
})

setup_highlights()

ls.config.setup({
  -- allow jumping back into a snippet if you moved outside of it
  history = true,
  -- since history is on, we need to sometimes remove snippets from the history
  -- that were expanded in the curent session but were subsequently deleted
  delete_check_events = 'TextChanged',
  -- show updates to all types of dynamic nodes as you type
  updateevents = 'TextChanged,TextChangedI',
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { '<- Choose', 'LuaSnipChoiceNode' } }
      },
    },
    [types.insertNode] = {
      active = {
        virt_text = { { '<- Write', 'LuaSnipInsertNode' } }
      }
    }
  }
})

local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local fmt = require("luasnip.extras.fmt").fmt
local m = require("luasnip.extras").m
local lambda = require("luasnip.extras").l

local function reload_luasnip()
  ls.cleanup()
  require('core.utils').reload_module 'cfg.plugins.luasnip'
end

local function setup_keymaps()
  -- set keybinds for both INSERT and VISUAL.
  vim.keymap.set('i', '<C-l>', function() ls.change_choice(1) end, {})
  vim.keymap.set('s', '<C-l>', function() ls.change_choice(1) end, {})
  vim.keymap.set('i', '<C-u>', select_choice, {})
  vim.keymap.set('n', '<leader><leader>s', reload_luasnip, { desc = 'Reload luasnip' })
end

setup_keymaps()

-- Load vscode snipperts from other plugins
-- require('luasnip.loaders.from_vscode').lazy_load()

local function define_lua_snippets()
  ls.add_snippets('lua', {
    s('lv',
      fmt(
        [[local {} = {}]], {
        i(1),
        i(2)
      }
      )),
    s(
      'lf',
      fmt(
        [[
          local function {}()
            {}
          end
        ]],
        {
          i(1),
          i(2)
        }
      )
    ),
    s(
      'fi',
      fmt(
        [[function() {} end]],
        {
          i(1)
        }
      )
    ),
    s(
      'req',
      fmt(
        [[local {} = require '{}']],
        {
          f(function(args)
            if args then
              local module = args[1][1]
              if module == '' then
                return ''
              end
              local parts = vim.split(module, '.', { plain = true })
              return parts[#parts]
            else
              return ''
            end
          end, { 1 }),
          i(1)
        }
      )
    ),
    s(
      'aug',
      fmt(
        [[local group = vim.api.nvim_create_augroup('{}', {{ clear = true }})]],
        {
          i(1)
        }
      )
    ),
    s(
      'au',
      fmt(
        [[
          vim.api.nvim_create_autocmd({{ '{}' }}, {{
            group = group,
            pattern = '{}',
            {},
            desc = '{}',
          }})
        ]],
        {
          i(1),
          i(2),
          c(3, {
            sn(nil, fmt([[callback = {}]], { i(1, 'func') })),
            sn(nil, fmt([[command = '{}']], { i(1) })),
          }),
          i(4),
        }
      )
    )
  })
end

define_lua_snippets()

local function define_go_snippets()
  ls.add_snippets('go', {
    s("fe", fmt([[fmt.Errorf("{}: %w", {})]], { i(1, ""), i(2, "err") })),
  })
end

define_go_snippets()

local function asana_task()
  return s('at', {
    t("["), c(1, {
      t("Asana Task"),
      t("Change Management Task"),
      i(nil, ""),
    }), t("]("), f(function() return vim.fn.getreg('+') end, {}), t(")")
  })
end

local function markdown_link()
  return s('lk', fmt('[{}]({})', {
    i(1),
    c(2, {
      i(nil),
      f(function() return vim.fn.getreg('+') end, {}),
    }),
  }))
end

local markdown_snippets = {
  asana_task(),
  markdown_link(),
}
ls.add_snippets('markdown', markdown_snippets)
ls.add_snippets('gitcommit', markdown_snippets)
