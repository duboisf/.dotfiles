return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  config = function()
    require('nvim-treesitter.configs').setup {
      textobjects = { -- syntax-aware textobjects
        select = {
          enable = true,
          lookahead = true,
          disable = {},
          keymaps = {
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
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["is"] = "@statement.inner",
            ["as"] = "@statement.outer",
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
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
          },
          goto_next_end = {
            ["]F"] = '@function.outer',
          },
          goto_previous_end = {
            ["[F"] = '@function.outer',
          },
        },
        swap = {
          -- mappings are configured using hydra in ~/.config/nvim/lua/cfg/plugins/hydra.lua
          enable = true,
        },
      }
    }
  end
}
