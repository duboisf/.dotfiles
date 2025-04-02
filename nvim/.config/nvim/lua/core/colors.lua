-- Lush uses a lot of globals so disable diagnostics for that
---@diagnostic disable: undefined-global

-- use :Lushify to enable dynamic rendering of the colorscheme 🤯

local lush = require 'lush'
local theme = require 'lush_theme.bluloco'

-- direction is used to darken or lighten colors based on the background
local direction = vim.opt.background:get() == 'dark' and 1 or -1

return lush.extends({ theme }).with(function(injected_functions)
  local sym = injected_functions.sym

  return {
    Statement { theme.Statement, gui = 'italic' },
    Boolean { theme.Boolean, gui = 'italic' },
    Comment { theme.Comment, gui = 'italic' },
    LineNr { fg = theme.LineNr.fg.darken(30 * direction) },
    LineNrAbove { fg = LineNr.fg.darken(15 * direction) },
    LineNrBelow { fg = LineNr.fg.darken(15 * direction) },
    TelescopeBorder { theme.TelescopeBorder, fg = theme.Statement.fg, bg = 'none' },
    TelescopeNormal { theme.Normal, blend = 15 },
    TelescopePromptNormal { TelescopeNormal, blend = 0 },
    sym('@tag.attribute') { theme['@tag.attribute'], gui = 'italic' },
    sym('@annotation') { theme['@annotation'], gui = 'italic' },
    -- goCoverageCovered is defined in the go.nvim plugin
    goCoverageCovered { theme.Function },
    sym('@lsp.mod.global') { fg = lush.hsl(20, 100, 50) }, -- global variables
    MiniIndentscopeSymbol { fg = lush.hsl(20, 100, 50) },

    CopilotSuggestion { theme.Comment, fg = theme.Comment.fg.lighten(30), gui = 'italic' },

    -- Treesitter diff
    sym('@text.diff.add') { theme.DiffAdd },
    sym('@text.diff.delete') { theme.DiffDelete },

    -- Fugitive diff
    diffAdded { theme.DiffAdd },
    darkDiffAdded { bg = theme.DiffAdd.bg.darken(30 * direction) },
    diffRemoved { theme.DiffDelete },

    LspReferenceRead { diffAdded },
    LspReferenceWrite { diffRemoved },

    sym('@text.strong') { theme.Bold, fg = theme.Normal.fg.li(50) },
    sym('@text.emphasis') { gui = 'italic' },
    sym('@text.reference') { theme['@text.uri'] },

    TextTitle { fg = theme.Statement.fg.li(10) },
    sym('@markup.heading.1') { TextTitle, bold = true, underline = true, standout = true },
    sym('@markup.heading.2') { TextTitle, bold = false, standout = true, fg = TextTitle.fg.li(10) },
    sym('@markup.heading.3') { underline = true, bold = true, fg = TextTitle.fg.li(10) },
    sym('@markup.heading.4') { TextTitle, },
    sym('@markup.heading.5') { TextTitle, italic = true },
    sym('@markup.heading.6') { TextTitle, italic = true, fg = TextTitle.fg.da(10) },
    sym('@markup.italic') { gui = 'italic' },

    sym('@text.danger') { theme.ErrorMsg },

    -- Don't use comment semantic highlighting, it hides treesitter comment highlighting like TODO/FIXME
    sym('@lsp.type.comment') {},
    sym('@lsp.mod.readonly') { theme.Constant },

    fugitiveStagedModifier { theme.Function },

    CmpItemKindUser { theme.CmpItemKindDefault },
  }
end)
