local onedark_config = function()
  local onedark = require 'onedark'

  onedark.setup {
    -- Main options --
    style = 'darker', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
    transparent = false, -- Show/hide background
    term_colors = true, -- Change terminal color as per the selected theme style
    ending_tildes = true, -- Show the end-of-buffer tildes. By default they are hidden
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
      darker = true, -- darker colors for diagnostic
      undercurl = true, -- use undercurl instead of underline for diagnostics
      background = true, -- use background color for virtual text
    },
  }

  onedark.load()
end

local colorscheme_plugins = {
  {
    'catppuccin/nvim',
  },
  {
    'EdenEast/nightfox.nvim',
  },
  {
    'navarasu/onedark.nvim',
    config = onedark_config,
  },
  {
    'folke/tokyonight.nvim',
    config = function()
      require('tokyonight').setup({
        style = 'storm',
      })
      vim.cmd [[colorscheme tokyonight]]
    end,
  },
  { "bluz71/vim-moonfly-colors", name = "moonfly" },
  {
    'uloco/bluloco.nvim',
    dependencies = { 'rktjmp/lush.nvim' },
    opts = {
      italics = true,
      -- when transparent, it uses the terminal's background color
      transparent = false,
    }
  },
}

for _, plugin in ipairs(colorscheme_plugins) do
  plugin.lazy = true
  plugin.priority = 1000
end

return colorscheme_plugins
