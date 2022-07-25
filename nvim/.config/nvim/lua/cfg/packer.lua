local fn = vim.fn
local utils = require("core.utils")

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
end

local autocmd = utils.autogroup('cfg#packer', true)
autocmd("BufWritePost", "*/cfg/packer.lua",
  "let b:disable_jump_to_last_position = 1 | source <afile> | PackerCompile",
  "Run :PackerCompile when the packer.lua config file gets saved"
)

require('packer').startup({ function(use)
  -- wrapper for use function to require our custom plugin configuration from the lua/cfg/plugins dir
  local function use_with_cfg(opts)
    local full_plugin_name = opts[1]
    local plugin_name = utils.packer.short_plugin_name(full_plugin_name)
    opts.config = "require 'cfg.plugins." .. plugin_name .. "'"
    use(opts)
  end

  local function notStartedByFirenvim()
    return vim.g.started_by_firenvim == nil
  end

  -- need to load this first to reap the benefits of the speedup provided by impatient.nvim
  use {
    'lewis6991/impatient.nvim',
    config = function() require('impatient') end
  }

  use 'wbthomason/packer.nvim'

  use { 'michaeljsmith/vim-indent-object', event = "VimEnter" }
  use { 'tpope/vim-commentary', event = "VimEnter" }
  use { 'tpope/vim-repeat', event = "VimEnter" }
  use { 'tpope/vim-unimpaired', event = "VimEnter" }

  -- show indentation guides
  use_with_cfg {
    'lukas-reineke/indent-blankline.nvim',
  }

  use {
    'kylechui/nvim-surround',
    event = 'VimEnter',
    config = function() require('nvim-surround').setup {} end
  }

  use {
    'ggandor/leap.nvim',
    config = function() require('leap').set_default_keymaps() end,
  }

  use {
    'windwp/nvim-autopairs',
    config = function() require 'cfg.plugins.autopairs' end,
  }

  use {
    'gpanders/editorconfig.nvim',
    cond = notStartedByFirenvim,
  }

  use {
    'mhinz/vim-startify',
    cond = notStartedByFirenvim,
  }

  use {
    "folke/twilight.nvim",
    event = 'VimEnter',
    config = function() require("twilight").setup {} end
  }

  use { 'tpope/vim-eunuch', event = "VimEnter" }

  -- vim-sensible sets things like ruler and laststatus which we don't want when we are using firenvim
  use {
    'tpope/vim-sensible',
    cond = notStartedByFirenvim,
  }

  use {
    'tsandall/vim-rego',
    ft = { 'rego' },
    config = function()
      vim.cmd [[
        " vim-rego configuration
        let g:formatdef_rego = '"opa fmt"'
        let g:formatters_rego = ['rego']
        let g:autoformat_autoindent = 0
        let g:autoformat_retab = 0

        aug fred#rego
          au!
          au BufWritePre *.rego Autoformat
        aug end
      ]]
    end
  }

  use {
    'tpope/vim-fugitive',
    config = function()
      -- open :G in a maximized window
      vim.cmd 'nnoremap <leader>g :G<CR>'
    end,
  }

  use { 'tpope/vim-rhubarb', after = 'vim-fugitive' }

  use {
    'rafcamlet/nvim-luapad',
    cmd = { 'Luapad' },
  }

  use { 'anuvyklack/keymap-layer.nvim' }

  use {
    'anuvyklack/hydra.nvim',
    event = 'VimEnter',
    config = function() require('cfg.plugins.hydra') end,
    after = { 'keymap-layer.nvim' }
  }

  -- show diff signs in the gutter
  use {
    'lewis6991/gitsigns.nvim',
    config = function() require 'cfg.plugins.gitsigns' end,
  }

  --[[

    dear
    sweet
    telescope

  --]]
  local function use_telescope()
    use {
      -- requires git, fd, ripgrep
      'nvim-telescope/telescope.nvim',
      requires = {
        'kyazdani42/nvim-web-devicons',
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
      },
      after = 'hydra.nvim',
      config = function() require 'cfg.plugins.telescope' end
    }

    -- support fzf syntax in the telescope prompt
    use {
      'nvim-telescope/telescope-fzf-native.nvim',
      after = 'telescope.nvim',
      run = 'make',
      config = function() require('telescope').load_extension 'fzf' end
    }

    -- search for github resources using telescope
    use {
      'nvim-telescope/telescope-github.nvim',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension 'gh' end
    }

    -- set vim.ui.select to telescope for a better picking experience for things
    -- like lsp code actions
    use {
      'nvim-telescope/telescope-ui-select.nvim',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension 'ui-select' end
    }
  end

  -- various commands to work with golang
  use {
    'fatih/vim-go',
    ft = { 'go', 'gomod' },
    config = function() require 'cfg.plugins.go' end
  }

  use {
    'norcalli/nvim-colorizer.lua',
    event = 'VimEnter',
    config = function() require('colorizer').setup() end
  }

  -- preview markdown in browser with live position synchronization
  use {
    'iamcco/markdown-preview.nvim',
    run = ':call mkdp#util#install()',
    ft = { 'markdown' },
    setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
  }

  -- use neovim in any text input in the browser 🤯
  use {
    'glacambre/firenvim',
    run = function() vim.fn['firenvim#install'](0) end,
    config = function() require('cfg.plugins.firenvim') end,
  }

  -- use popup window when using the vim.notify api
  use {
    'rcarriga/nvim-notify',
    after = 'telescope.nvim',
    config = function() require('cfg.plugins.nvim_notify') end,
  }

  -- fast and easily configurable status line written in lua 🌕
  use {
    'nvim-lualine/lualine.nvim',
    cond = notStartedByFirenvim,
    config = function() require 'cfg.plugins.lualine' end,
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  -- file browser
  use {
    'kyazdani42/nvim-tree.lua',
    config = function() require('cfg.plugins.nvim-tree') end,
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
  }

  use {
    'sbdchd/neoformat',
    config = function()
      vim.g.neoformat_try_node_exe = 1
    end
  }

  --[[

    dear
    sweet
    LSP

  --]]
  local function use_language_servers()
    -- don't hunt around the web to install language servers
    use 'williamboman/nvim-lsp-installer'

    -- this is needed to fix lsp doc highlight
    use { 'antoinemadec/FixCursorHold.nvim' }

    -- simplify language server configuration
    use_with_cfg {
      'neovim/nvim-lspconfig',
      after = {
        'aerial.nvim',
        'nvim-cmp',
        'nvim-lsp-installer',
      }
    }
  end

  --[[

    dear
    sweet
    completion

  --]]
  local function use_completion()
    -- snippets engine written in lua
    use {
      'L3MON4D3/LuaSnip',
      after = { 'nvim-cmp' },
      config = function() require 'cfg.plugins.luasnip' end,
    }
    for _, source in ipairs({
      -- complete words from other buffers
      'hrsh7th/cmp-buffer',
      -- completion when in nvim commandline
      'hrsh7th/cmp-cmdline',
      -- complete emojis like :tada:
      'hrsh7th/cmp-emoji',
      -- completion for filesystem paths
      'hrsh7th/cmp-path',
      -- completion for luasnip snippets
      'saadparwaiz1/cmp_luasnip',
    }) do
      use { source, after = 'nvim-cmp' }
    end

    -- fancy completion
    use {
      'hrsh7th/nvim-cmp',
      config = function() require 'cfg.plugins.cmp' end,
      requires = {
        -- add vscode-line pictograms in completion popup
        'onsails/lspkind.nvim',
        -- completion suggestions from language server
        'hrsh7th/cmp-nvim-lsp',
      },
      after = { 'nvim-autopairs' }
    }
  end

  --[[

    dear
    sweet
    treesitter

  --]]
  local function use_treesitter()

    use {
      'nvim-treesitter/nvim-treesitter',
      event = 'VimEnter',
      config = function() require 'cfg.plugins.treesitter' end,
      run = ':TSUpdate',
    }

    use {
      'nvim-treesitter/playground',
      after = 'nvim-treesitter',
    }

    use {
      'nvim-treesitter/nvim-treesitter-context',
      config = function() require 'treesitter-context'.setup {} end,
      after = 'nvim-treesitter',
    }

    use {
      'nvim-treesitter/nvim-treesitter-textobjects',
      after = 'nvim-treesitter',
    }

    use {
      'p00f/nvim-ts-rainbow',
      after = 'nvim-treesitter',
    }
  end

  local function use_colorscheme()
    -- colorscheme
    use {
      'rakr/vim-one',
      config = function() require 'cfg.plugins.colors' end,
      disable = true,
    }

    -- colorscheme
    use {
      'navarasu/onedark.nvim',
      config = function()
        local onedark = require 'onedark'
        onedark.setup {
          -- Main options --
          style = 'darker', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
          transparent = false, -- Show/hide background
          term_colors = true, -- Change terminal color as per the selected theme style
          ending_tildes = true, -- Show the end-of-buffer tildes. By default they are hidden
          cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu
          -- toggle theme style
          toggle_style_key = '<leader>ts',
          -- List of styles to toggle between
          toggle_style_list = { 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light' },
          -- Change code style
          -- Options are italic, bold, underline, none
          -- You can configure multiple style with comma seperated, For e.g., keywords = 'italic,bold'
          code_style = {
            comments = 'italic',
            keywords = 'none',
            functions = 'none',
            strings = 'none',
            variables = 'none'
          },
          -- Custom Highlights --
          colors = {}, -- Override default colors
          highlights = { -- Override highlight groups
            -- some parens were the same color as the background when highlighted
            MatchParen = { bg = '$red', fmt = 'bold' },
          },
          -- Plugins Config --
          diagnostics = {
            darker = true, -- darker colors for diagnostic
            undercurl = true, -- use undercurl instead of underline for diagnostics
            background = true, -- use background color for virtual text
          },
        }
        onedark.load()
      end
    }
  end

  -- show the available mappings when pressing part of a multi-key mapping
  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  -- color picker, use the PickColor command
  use {
    'ziontee113/color-picker.nvim',
    config = function() require 'color-picker' end,
  }

  -- code outline
  use {
    'stevearc/aerial.nvim',
    config = function() require('aerial').setup() end
  }

  -- take notes zettelkasten-style
  use {
    'mickael-menu/zk-nvim',
    config = function() require 'cfg.plugins.zk' end
  }

  use_colorscheme()
  use_completion()
  use_language_servers()
  use_telescope()
  use_treesitter()

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end, config = { profile = { enable = true, threshold = 1 } } })
