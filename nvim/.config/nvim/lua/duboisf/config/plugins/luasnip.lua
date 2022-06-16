local ls = require "luasnip"
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

-- Load vscode snipperts from other plugins
require('luasnip.loaders.from_vscode').lazy_load()

ls.add_snippets(nil, {
  gitcommit = {
    s({
      trig = "ast",
      namr = "Asana Task",
      dscr = "Create an asana task markdown link with the text in the copy buffer",
    }, {
      t("["), i(1, "Asana Task"), t("]("), f(function() return vim.fn.getreg('+') end), t(")")
    }),
  },
})
