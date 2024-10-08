local onedark_config = function()
  local onedark = require 'onedark'

  onedark.setup {
    -- Main options --
    style = 'darker',             -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
    transparent = false,          -- Show/hide background
    term_colors = true,           -- Change terminal color as per the selected theme style
    ending_tildes = true,         -- Show the end-of-buffer tildes. By default they are hidden
    cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu
    -- toggle theme style
    toggle_style_key = '<leader>ts',
    -- List of styles to toggle between
    toggle_style_list = { 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light' },
    -- Change code style
    -- Options are italic, bold, underline, none
    -- You can configure multiple style with comma seperated, For e.g., keywords = 'italic,bold'
    code_style = {
      comments = 'italic',
      keywords = 'bold',
      functions = 'none',
      strings = 'none',
      variables = 'none'
    },
    -- Override default colors
    colors = {
      diff_add = '#0f2703',
      diff_delete = '#370a02',
    },
    -- Custom Highlights --
    highlights = {
      Search = { fg = '$black', bg = '#ff6d00' },
      -- some parens were the same color as the background when highlighted
      MatchParen = { bg = '$dark_red' },
      goCoverageUncovered = { fg = '$dark_red' },
    },
    -- Plugins Config --
    diagnostics = {
      darker = true,     -- darker colors for diagnostic
      undercurl = true,  -- use undercurl instead of underline for diagnostics
      background = true, -- use background color for virtual text
    },
  }

  onedark.load()
end

return {
  'rktjmp/lush.nvim',
  {
    'navarasu/onedark.nvim',
    lazy = true,
    config = onedark_config,
    priority = 1000,
  },
  {
    'uloco/bluloco.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require("bluloco").setup({
        style       = "auto", -- "auto" | "dark" | "light"
        transparent = false,
        italics     = true,
        guicursor   = true,
      })
      vim.opt.termguicolors = true
      vim.cmd.colorscheme 'fred-bluloco'
    end,
    dependencies = { 'duboisf/crepuscule.nvim' }
  },
  {
    'duboisf/crepuscule.nvim',
    config = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
}
