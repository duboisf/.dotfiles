local ls = require 'luasnip'
local types = require 'luasnip.util.types'

local higroup = vim.api.nvim_create_augroup('duboisf#config#plugins#luasnip', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  group = higroup,
  pattern = "*",
  callback = function()
    local c = vim.cmd
    c 'hi LuaSnipChoiceNode guifg=#d65d0e'
    c 'hi LuaSnipInsertNode guifg=#fabd2f'
  end,
})

ls.config.setup({
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { "<- Choose", "LuaSnipChoiceNode" } }
      },
    },
    [types.insertNode] = {
      active = {
        virt_text = { { "<- Write", "LuaSnipInsertNode" } }
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

local date = function() return { os.date('%Y-%m-%d') } end

-- set keybinds for both INSERT and VISUAL.
vim.api.nvim_set_keymap("i", "<C-l>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("s", "<C-l>", "<Plug>luasnip-next-choice", {})

-- Load vscode snipperts from other plugins
require('luasnip.loaders.from_vscode').lazy_load()

ls.add_snippets(nil, {
  all = {
    s({
      trig = "ast",
      namr = "Asana Task",
      dscr = "Create an asana task markdown link with the text in the copy buffer",
    }, {
      t("["), c(1, {
        t("Asana Task"),
        t("Change Management Task"),
        i(nil, ""),
      }), t("]("), f(function() return vim.fn.getreg('+') end, {}), t(")")
    })
  },

  lua = {
    s({
      trig = 'lf',
      namr = 'lambda function',
      dscr = 'Creates an inline lambda function used to pass as a parameter',
    }, {
      t("function() "), i(1, ""), t(" end"),
    }),
  },
})
