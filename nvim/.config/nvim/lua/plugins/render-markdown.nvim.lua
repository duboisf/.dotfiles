---@type LazyPluginSpec
return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'echasnovski/mini.icons'
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    debounce = 10,
    render_modes = true,
    sign = {
      enabled = false,
    },
    file_types = { 'markdown', 'codecompanion' },
    win_options = {
      conceallevel = { rendered = 2 },
    },
    overrides = {
      buftype = {
        nofile = {
          render_modes = { 'n', 'c', 'i' },
        },
      },
    },
    code = {
      language_pad = 1,
      left_pad = 0,
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
