return {
  {
    'uloco/bluloco.nvim',
    dependencies = {
      'rktjmp/lush.nvim',
      'duboisf/crepuscule.nvim'
    },
    priority = 1000,
    opts = {
      style       = "auto", -- "auto" | "dark" | "light"
      transparent = false,
      italics     = true,
      guicursor   = true,
    },
    config = function(_, opts)
      require("bluloco").setup(opts)
      vim.opt.termguicolors = true
      vim.cmd.colorscheme 'fred-bluloco'
    end,
  },
  {
    'duboisf/crepuscule.nvim',
    config = true,
    enabled = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
}
