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
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = '*',
        callback = function()
          if vim.bo.buftype == 'nofile' then
            vim.b.miniindentscope_disable = true
          end
        end
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
      options = {
        use_as_default_explorer = false,
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
  {
    'echasnovski/mini.surround',
    config = function()
      require('mini.surround').setup({
        mappings = {
          add = 'ys',
          delete = 'ds',
          find = '',
          find_left = '',
          highlight = '',
          replace = 'cs',

          -- Add this only if you don't want to use extended mappings
          suffix_last = '',
          suffix_next = '',
        },
        search_method = 'cover_or_next',
      })

      -- Remap adding surrounding to Visual mode selection
      vim.keymap.del('x', 'ys')
      vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

      -- Make special mapping for "add surrounding for line"
      vim.keymap.set('n', 'yss', 'ys_', { remap = true })
    end,
  },
}
