require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { 'c', 'rust' }, -- list of language that will be disabled
    custom_captures = { -- mapping of user defined captures to highlight groups
      ["foo.bar"] = "Identifier" -- highlight own capture @foo.bar with highlight group "Identifier", see :h nvim-treesitter-query-extensions
    },
  },
  incremental_selection = {
    enable = true,
    keymaps = {},
    -- keymaps = { -- mappings for incremental selection (visual mappings)
    --   init_selection    = 'gs', -- maps in normal mode to init the node/scope selection
    --   node_incremental  = 'gj', -- increment to the upper named parent
    --   scope_incremental = 'gl', -- increment to the upper scope (as defined in locals.scm)
    --   node_decremental  = 'gk', -- decrement to the previous node
    -- }
  },
  indent = {
    enable = true,
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
  textobjects = { -- syntax-aware textobjects
    enable = false,
    lookahead = true,
    disable = {},
    keymaps = {
      ["iL"] = { -- you can define your own textobjects directly here
        python = "(function_definition) @function",
        cpp = "(function_definition) @function",
        c = "(function_definition) @function",
        java = "(method_declaration) @function"
      },
      -- or you use the queries from supported languages with textobjects.scm
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
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
    }
  },
  ensure_installed = 'all' -- one of 'all', 'maintained', or a list of languages
}
