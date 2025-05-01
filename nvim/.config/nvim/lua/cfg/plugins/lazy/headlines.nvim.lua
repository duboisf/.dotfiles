---@type LazyPluginSpec
return {
  "lukas-reineke/headlines.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  enabled = false,
  opts = {
    markdown = {
      bullets = { " ❶ ", "②", "③", "④" },
    },
  }
}
