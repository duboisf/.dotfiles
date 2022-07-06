local fn = vim.fn
local utils = require("core.utils")
local autogroup = utils.autogroup
local autocmd = utils.autocmd

-- define a bunch of autocommands to help with lazy loading
local group = autogroup('cfg#packer', true)

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
end

autocmd(group, "BufWritePost", "*/cfg/packer.lua",
  "let b:disable_jump_to_last_position = 1 | source <afile> | PackerCompile", {
  desc = "Run packer.compile() when the packer.lua config file gets saved",
})

require('packer').startup({ function(use)
  local function notStartedByFirenvim()
    return vim.g.started_by_firenvim == nil
  end

  use 'wbthomason/packer.nvim'

  use { 'justinmk/vim-sneak', event = "VimEnter" }
  use { 'michaeljsmith/vim-indent-object', event = "VimEnter" }
  use { 'tpope/vim-commentary', event = "VimEnter" }
  use { 'tpope/vim-repeat', event = "VimEnter" }
  use { 'tpope/vim-surround', event = "VimEnter" }
  use { 'tpope/vim-unimpaired', event = "VimEnter" }

  use {
    'windwp/nvim-autopairs',
    config = function() require 'nvim-autopairs'.setup {} end,
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
      -- Open :G in a maximized window
      vim.cmd 'nnoremap <leader>g :G<CR>'
    end,
  }

  use {
    'rafcamlet/nvim-luapad',
    cmd = { 'Luapad' },
  }

  use { 'tpope/vim-rhubarb', after = 'vim-fugitive' }

  use { 'anuvyklack/keymap-layer.nvim' }

  use {
    'anuvyklack/hydra.nvim',
    event = 'VimEnter',
    config = function() require('cfg.plugins.hydra') end,
    after = { 'keymap-layer.nvim' }
  }

  use {
    'lewis6991/gitsigns.nvim',
    config = function() require 'cfg.plugins.gitsigns' end,
  }

  use {
    -- Requires git, fzf, python3, ripgrep
    -- Optional bat(like cat but 10x nicer!), exa(like ls but nicer!)
    'nvim-telescope/telescope.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons',
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    },
    config = function() require 'cfg.plugins.telescope' end
  }

  --
  -- telescope
  --
  use {
    'nvim-telescope/telescope-github.nvim',
    after = 'telescope.nvim',
    config = function() require 'telescope'.load_extension 'gh' end
  }

  use {
    'fatih/vim-go',
    ft = { 'go', 'gomod' },
    config = function() require 'cfg.plugins.go' end
  }

  use {
    'norcalli/nvim-colorizer.lua',
    event = 'VimEnter',
    config = function() require "colorizer".setup() end
  }

  use {
    'iamcco/markdown-preview.nvim',
    run = ':call mkdp#util#install()',
    ft = { 'markdown' },
    setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
  }

  --
  -- treesitter
  --
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
    'p00f/nvim-ts-rainbow',
    after = 'nvim-treesitter',
  }

  use {
    'glacambre/firenvim',
    run = function() vim.fn['firenvim#install'](0) end,
    config = function() require('cfg.plugins.firenvim') end,
  }

  use {
    'rcarriga/nvim-notify',
    after = 'telescope.nvim',
    config = function() require('cfg.plugins.nvim_notify') end,
  }

  use {
    'nvim-lualine/lualine.nvim',
    cond = notStartedByFirenvim,
    config = function() require 'cfg.plugins.lualine' end,
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  use {
    'kyazdani42/nvim-tree.lua',
    config = function() require('cfg.plugins.nvim-tree') end,
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
  }

  --
  -- nvim-cmp
  --
  for _, source in ipairs({
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-emoji',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-path',
    'saadparwaiz1/cmp_luasnip',
  }) do
    use { source, after = 'nvim-cmp' }
  end

  use {
    'hrsh7th/nvim-cmp',
    config = function() require 'cfg.plugins.cmp' end,
    requires = {
      'onsails/lspkind.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    after = {
      'nvim-autopairs',
    }
  }

  use 'williamboman/nvim-lsp-installer'

  use {
    'sbdchd/neoformat',
    config = function()
      vim.g.neoformat_try_node_exe = 1
    end
  }

  use {
    'neovim/nvim-lspconfig',
    config = function() require 'cfg.plugins.lsp' end,
    after = {
      'nvim-cmp',
      'nvim-lsp-installer',
    }
  }

  use {
    'L3MON4D3/LuaSnip',
    after = {
      'nvim-cmp'
    },
    config = function() require 'cfg.plugins.luasnip' end,
  }

  use {
    'rakr/vim-one',
    config = function()
      vim.cmd 'colorscheme one'
      vim.g.background = 'dark'
      vim.cmd [[
        hi clear Search
        hi default Search gui=reverse guifg=#ff6d00
      ]]
    end
  }

  use {
    'mickael-menu/zk-nvim',
    config = function() require('cfg.plugins.zk') end
  }

  -- Render markdown files directly inside a buffer using glow
  use { 'ellisonleao/glow.nvim' }

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end, config = { profile = { enable = true, threshold = 1 } } })
