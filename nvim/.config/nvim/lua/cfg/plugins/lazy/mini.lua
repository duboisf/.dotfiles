return {
  'echasnovski/mini.nvim',
  config = function()
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
    require('mini.splitjoin').setup({})
    require('mini.surround').setup({})
  end,
  version = false
}
