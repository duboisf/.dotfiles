return {
  'echasnovski/mini.nvim',
  config    = function()
    local wk = require('which-key')

    require('mini.comment').setup({})
    require('mini.cursorword').setup({})

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

    local MiniFiles = require('mini.files')
    MiniFiles.setup({
      mappings = {
        go_in_plus = "<CR>",
      },
    })
    wk.add({
      "<leader>v",
      function()
        if not MiniFiles.close() then
          MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
        end
      end,
      desc =
      "Open file browser in current file's directory"
    })

    require('mini.splitjoin').setup({})
    require('mini.surround').setup({})
  end,
  version   = false,
  depencies = {
    "folke/which-key.nvim",
  }
}
