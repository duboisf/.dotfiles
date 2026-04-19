return {
  "ray-x/go.nvim",
  dependencies = { -- optional packages
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
  },
  opts = {
    -- lsp_keymaps = false,
    -- other options
  },
  event = { "CmdlineEnter" },
  ft = { "go", 'gomod' },
}
