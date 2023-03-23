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
    local MiniIndentscope = require('mini.indentscope')
    MiniIndentscope.setup({
      draw = {
        animation = MiniIndentscope.gen_animation.quadratic({
          easing = 'in-out',
          duration = 100,
          unit = 'total'
        })
      }
    })
    require('mini.jump').setup({})
    require('mini.pairs').setup({})
    require('mini.splitjoin').setup({})
    require('mini.surround').setup({})
  end,
  version = false
}
