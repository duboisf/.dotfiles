return {
  ---@type LazyPluginSpec
  {
    'nvim-treesitter/nvim-treesitter',
    enabled = true,
    build = ':TSUpdate',
    ---@module 'nvim-treesitter.configs'
    ---@type TSConfig
    opts = {
      sync_install = false,
      ignore_install = {},
      auto_install = false,
      modules = {},
      ensure_installed = {
        'bash',
        'comment',
        'diff',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'gomod',
        'gosum',
        'gotmpl',
        'json',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'mermaid',
        'query',
        'regex',
        'ruby',
        'terraform',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      },
      highlight = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        -- mappings are configured using hydra in ~/.config/nvim/lua/cfg/plugins/hydra.lua
        keymaps = {                        -- mappings for incremental selection (visual mappings)
          init_selection    = 'gs',        -- maps in normal mode to init the node/scope selection
          node_incremental  = '<C-Down>',  -- increment to the upper named parent
          scope_incremental = '<C-Right>', -- increment to the upper scope (as defined in locals.scm)
          node_decremental  = '<C-Up>',    -- decrement to the previous node
        }
      },
      indent = {
        enable = true,
        disable = { 'yaml' }
      },
    },
    main = 'nvim-treesitter.configs',
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')

      local select_keymaps = {
        -- custom captures
        al = '@list.outer',
        il = '@list.inner',
        ak = '@key.outer',
        ik = '@key.inner',

        -- the queries are in textobjects.scm
        aa = '@assignment.outer',
        ia = '@assignment.inner',
        af = '@function.outer',
        ['if'] = '@function.inner',
        ap = '@parameter.outer',
        ip = '@parameter.inner',
        aC = '@class.outer',
        iC = '@class.inner',
        ac = '@conditional.outer',
        ic = '@conditional.inner',
        ab = '@block.outer',
        ib = '@block.inner',
        aL = '@loop.outer',
        iL = '@loop.inner',
        ['is'] = '@statement.inner',
        as = '@statement.outer',
        ad = '@comment.outer',
        am = '@call.outer',
        im = '@call.inner',
      }
      for lhs, capture in pairs(select_keymaps) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(capture, 'textobjects')
        end)
      end

      local move_keymaps = {
        goto_next_start = {
          [']F'] = '@function.outer',
          ['<C-j>'] = '@parameter.inner',
        },
        goto_previous_start = {
          ['[F'] = '@function.outer',
          ['<C-k>'] = '@parameter.inner',
        },
      }
      for fn, maps in pairs(move_keymaps) do
        for lhs, capture in pairs(maps) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            move[fn](capture, 'textobjects')
          end)
        end
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      enable = true,
      separator = '─',
    },
  }
}
