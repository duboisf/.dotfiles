-- Lush uses a lot of globals so disable diagnostics for that
---@diagnostic disable: undefined-global

-- use :Lushify to enable dynamic rendering of the colorscheme 🤯

local lush = require 'lush'
local bluloco = require 'lush_theme.bluloco'
local theme = lush.extends({ bluloco }).with(function(injected_functions)
  local sym = injected_functions.sym
  return {
    Statement { bluloco.Statement, gui = 'italic' },
    Boolean { bluloco.Boolean, gui = 'italic' },
    Comment { bluloco.Comment, gui = 'italic' },
    LineNr { fg = bluloco.LineNr.fg.darken(10) },
    LineNrAbove { fg = LineNr.fg.darken(35) },
    LineNrBelow { fg = LineNr.fg.darken(35) },
    TelescopeBorder { bluloco.TelescopeBorder, fg = bluloco.Statement.fg, bg = 'none' },
    TelescopeNormal { bluloco.Normal, blend = 15 },
    sym('@tag.attribute') { bluloco['@tag.attribute'], gui = 'italic' },
    sym('@annotation') { bluloco['@annotation'], gui = 'italic' },
    -- goCoverageCovered is defined in the go.nvim plugin
    goCoverageCovered { bluloco.Function },
    sym('@lsp.mod.global') { fg = lush.hsl(20, 100, 50) } -- global variables
  }
end)

return theme
