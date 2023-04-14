-- Lush uses a lot of globals so disable diagnostics for that
---@diagnostic disable: undefined-global

-- use :Lushify to enable dynamic rendering of the colorscheme 🤯

local lush = require 'lush'
local theme = require 'lush_theme.bluloco'

return lush.extends({ theme }).with(function(injected_functions)
  local sym = injected_functions.sym

  return {
    Statement { theme.Statement, gui = 'italic' },
    Boolean { theme.Boolean, gui = 'italic' },
    Comment { theme.Comment, gui = 'italic' },
    LineNr { fg = theme.LineNr.fg.darken(20) },
    LineNrAbove { fg = LineNr.fg.darken(36) },
    LineNrBelow { fg = LineNr.fg.darken(36) },
    TelescopeBorder { theme.TelescopeBorder, fg = theme.Statement.fg, bg = 'none' },
    TelescopeNormal { theme.Normal, blend = 15 },
    sym('@tag.attribute') { theme['@tag.attribute'], gui = 'italic' },
    sym('@annotation') { theme['@annotation'], gui = 'italic' },
    -- goCoverageCovered is defined in the go.nvim plugin
    goCoverageCovered { theme.Function },
    sym('@lsp.mod.global') { fg = lush.hsl(20, 100, 50) }, -- global variables
    MiniIndentscopeSymbol { fg = lush.hsl(20, 100, 50) },
    -- diff
    sym('@text.diff.add') { fg = lush.hsl(100, 100, 50) }, -- diff delete
    sym('@text.diff.delete') { fg = lush.hsl(0, 100, 50) }, -- diff delete
    sym('@text.reference') { theme['@text.uri'] },
    LspReferenceRead { fg = lush.hsl(0, 0, 0), bg = lush.hsl(100, 100, 50) },
    LspReferenceWrite { fg = lush.hsl(0, 0, 0), bg = lush.hsl(10, 100, 50) },
  }
end)
