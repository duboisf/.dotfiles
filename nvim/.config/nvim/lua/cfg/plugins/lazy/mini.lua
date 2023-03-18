return {
  'echasnovski/mini.nvim',
  config = function()
    require('mini.indentscope').setup()
    require('mini.jump').setup()
  end,
  version = false
}
