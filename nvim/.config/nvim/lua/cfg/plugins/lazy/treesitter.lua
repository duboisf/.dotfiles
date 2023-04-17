local config = function()
  local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
  parser_config.gotmpl = {
    install_info = {
      url = 'https://github.com/ngalaiko/tree-sitter-go-template',
      files = { 'src/parser.c' },
    },
    filetype = 'gotmpl',
    used_by = { 'gohtmltmpl', 'gotexttmpl', 'gotmpl' }
  }

  require('nvim-treesitter.configs').setup {
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
      'query',
      'regex',
      'terraform',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
    },
    highlight = {
      enable = true, -- false will disable the whole extension
    },
    incremental_selection = {
      enable = true,
      -- mappings are configured using hydra in ~/.config/nvim/lua/cfg/plugins/hydra.lua
      keymaps = { -- mappings for incremental selection (visual mappings)
        init_selection    = 'gs', -- maps in normal mode to init the node/scope selection
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
  }
end

return {
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = true,
  },
  'nvim-treesitter/playground',
  'p00f/nvim-ts-rainbow',
  {
    'nvim-treesitter/nvim-treesitter',
    build = function()
      require('nvim-treesitter.install').update()
    end,
    config = config,
  },
}
