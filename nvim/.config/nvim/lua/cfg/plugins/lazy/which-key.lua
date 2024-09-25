return {
  "folke/which-key.nvim",
  config = function()
    local wk = require("which-key")
    wk.add({
      { "<C-w><space>", function() wk.show({ keys = "<C-w>", loop = true, desc = "Hydra-mode window actions" }) end },
    })
  end,
  event = "VeryLazy",
  opts = {
    preset = "helix",
  },
}
