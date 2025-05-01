---@type LazyPluginSpec
return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'echasnovski/mini.nvim'
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    code = {
      language_pad = 1,
      left_pad = 2,
      style = 'full',
      border = 'thin',
      width = "block",
      right_pad = 2,
    },
    heading = {
      position = 'inline',
      left_pad = 1,
      border = true,
      border_virtual = true,
    },
  },
}
