return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",  -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local neogit = require('neogit')
    neogit.setup({
      kind = 'auto',
      integrations = {
        telescope = false,
      },
    })
    vim.keymap.set('n', '<A-s>', neogit.action('branch', 'checkout_recent_branch'))
  end
}
