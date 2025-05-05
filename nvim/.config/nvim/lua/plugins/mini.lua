return {
  -- { 'echasnovski/mini.comment', opts = {} },
  -- { 'echasnovski/mini.cursorword', opts = {} },
  {
    'echasnovski/mini.icons',
    opts = {},
    config = function(_, opts)
      local MiniIcons = require('mini.icons')
      MiniIcons.setup(opts)
      MiniIcons.mock_nvim_web_devicons()
    end
  },
  {
    'echasnovski/mini.indentscope',
    config = function()
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
    end,
  },
  {
    'echasnovski/mini.files',
    opts = {
      mappings = {
        go_in = 'L',
        go_in_plus = "<CR>",
        go_out = 'H',
        go_out_plus = '',
      },
    },
    config = function(_, opts)
      local MiniFiles = require('mini.files')
      MiniFiles.setup(opts)
      vim.keymap.set('n', '<leader>v', function()
        if not MiniFiles.close() then
          MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
        end
      end, {
        desc = "Open file browser in current file's directory",
        noremap = true,
        silent = true
      })
    end
  },
  -- {
  --   'echasnovski/mini.surround',
  --   opts = {},
  -- },
}
