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
    LineNr { fg = theme.LineNr.fg.darken(30) },
    LineNrAbove { fg = LineNr.fg.darken(15) },
    LineNrBelow { fg = LineNr.fg.darken(15) },
    TelescopeBorder { theme.TelescopeBorder, fg = theme.Statement.fg, bg = 'none' },
    TelescopeNormal { theme.Normal, blend = 15 },
    sym('@tag.attribute') { theme['@tag.attribute'], gui = 'italic' },
    sym('@annotation') { theme['@annotation'], gui = 'italic' },
    -- goCoverageCovered is defined in the go.nvim plugin
    goCoverageCovered { theme.Function },
    sym('@lsp.mod.global') { fg = lush.hsl(20, 100, 50) }, -- global variables
    MiniIndentscopeSymbol { fg = lush.hsl(20, 100, 50) },

    -- Treesitter diff
    sym('@text.diff.add') { theme.DiffAdd },
    sym('@text.diff.delete') { theme.DiffDelete },

    -- Fugitive diff
    diffAdded { theme.DiffAdd },
    darkDiffAdded { bg = theme.DiffAdd.bg.darken(30) },
    diffRemoved { theme.DiffDelete },

    LspReferenceRead { diffAdded },
    LspReferenceWrite { diffRemoved },
    sym('@text.strong') { theme.Bold, fg = theme.Normal.fg.li(50) },
    sym('@text.emphasis') { gui = 'italic' },
    sym('@text.reference') { theme['@text.uri'] },
    TextTitle { fg = theme.Statement.fg.lighten(10), italic = true },
    sym('@text.title.h1') { TextTitle },
    sym('@text.title.h2') { TextTitle, fg = TextTitle.fg.darken(10) },
    sym('@text.title.h3') { TextTitle, fg = TextTitle.fg.darken(20) },
    sym('@text.title.h4') { TextTitle, fg = TextTitle.fg.darken(30) },
    sym('@text.title.h5') { TextTitle, fg = TextTitle.fg.darken(40) },
    sym('@text.title.h6') { TextTitle, fg = TextTitle.fg.darken(50) },
    sym('@text.danger') { theme.ErrorMsg },

    -- Don't use comment semantic highlighting, it hides treesitter comment highlighting like TODO/FIXME
    sym('@lsp.type.comment') {},
    sym('@lsp.mod.readonly') { theme.Constant },
  }
end)
