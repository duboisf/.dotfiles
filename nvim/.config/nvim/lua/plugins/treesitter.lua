return {
  ---@type LazyPluginSpec
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'nushell/tree-sitter-nu',
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/playground',
    },
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
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'mermaid',
        'query',
        'regex',
        'ruby',
        'terraform',
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
        keymaps = {                    -- mappings for incremental selection (visual mappings)
          init_selection    = 'gs',    -- maps in normal mode to init the node/scope selection
          node_incremental  = '<C-j>', -- increment to the upper named parent
          scope_incremental = '<C-l>', -- increment to the upper scope (as defined in locals.scm)
          node_decremental  = '<C-k>', -- decrement to the previous node
        }
      },
      indent = {
        enable = true,
        disable = { 'yaml' }
      },
      playground = {
        enable = true,
        persist_queries = true,
      },
      rainbow = {
        enable = true,
        extended_mode = true,
      },
      refactor = {
        highlight_definitions = {
          enable = true
        },
        highlight_current_scope = {
          enable = true
        },
        smart_rename = {
          enable = true,
          keymaps = {
            smart_rename = "grr" -- mapping to rename reference under cursor
          }
        },
        navigation = {
          enable = true,
          keymaps = {
            goto_definition = "gnd", -- mapping to go to definition of symbol under cursor
            list_definitions = "gnD" -- mapping to list all definitions in current file
          }
        }
      },
      textobjects = {
        -- syntax-aware textobjects
        select = {
          enable = true,
          lookahead = true,
          disable = {},
          keymaps = {
            -- custom captures
            ["al"] = "@list.outer",
            ["il"] = "@list.inner",

            -- the queries are in textobjects.scm
            ["aa"] = "@assignment.outer",
            ["ia"] = "@assignment.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ap"] = "@parameter.outer",
            ["ip"] = "@parameter.inner",
            ["aC"] = "@class.outer",
            ["iC"] = "@class.inner",
            ["ac"] = "@conditional.outer",
            ["ic"] = "@conditional.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            ["aL"] = "@loop.outer",
            ["iL"] = "@loop.inner",
            ["iS"] = "@statement.inner",
            ["aS"] = "@statement.outer",
            ["ad"] = "@comment.outer",
            ["am"] = "@call.outer",
            ["im"] = "@call.inner"
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            ['<C-Down>'] = '@parameter.inner'
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['<C-Up>'] = '@parameter.inner'
          },
          goto_next_end = {
            ["]F"] = '@function.outer',
          },
          goto_previous_end = {
            ["[F"] = '@function.outer',
          },
        },
        swap = {
          enable = true,
        },
      }
    },
    main = 'nvim-treesitter.configs',
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
