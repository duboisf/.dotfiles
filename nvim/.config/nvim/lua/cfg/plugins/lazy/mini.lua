return {
  'echasnovski/mini.nvim',
  config = function()
    local animate = require 'mini.animate'
    require('mini.animate').setup({
      cursor = {
        timing = animate.gen_timing.quadratic({
          easing = 'in-out',
          duration = 50,
          unit = 'total'
        })
      },
      scroll = {
        enable = false,
      }
    })
    require('mini.comment').setup({})
    require('mini.indentscope').setup({})
    require('mini.jump').setup({})
    require('mini.pairs').setup({})
    require('mini.surround').setup({})
  end,
  version = false
}
