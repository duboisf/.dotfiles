return {
  'echasnovski/mini.nvim',
  config = function()
    require('mini.indentscope').setup()
    require('mini.jump').setup()
    require('mini.surround').setup()
  end,
  version = false
}
