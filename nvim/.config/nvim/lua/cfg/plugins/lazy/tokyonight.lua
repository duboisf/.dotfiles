return {
  "folke/tokyonight.nvim",
  config = function()
    require('tokyonight').setup({
      style = 'storm',
    })
    vim.cmd [[colorscheme tokyonight]]
  end,
  priority = 1000, -- load first since this is a colorscheme
}
