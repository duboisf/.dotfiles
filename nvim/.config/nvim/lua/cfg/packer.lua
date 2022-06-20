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

autocmd(group, "BufWritePost", "*/cfg/packer.lua", "source <afile> | PackerCompile", {
  desc = "Run packer.compile() when the packer.lua config file gets saved",
})

require('packer').startup({ function(use)
  use 'wbthomason/packer.nvim'

  use { 'justinmk/vim-sneak', event = "VimEnter" }
  use { 'michaeljsmith/vim-indent-object', event = "VimEnter" }
  use { 'tpope/vim-commentary', event = "VimEnter" }
  use { 'tpope/vim-repeat', event = "VimEnter" }
  use { 'tpope/vim-surround', event = "VimEnter" }
  use { 'tpope/vim-unimpaired', event = "VimEnter" }

  use {
    'windwp/nvim-autopairs',
    event = 'VimEnter',
    config = function() require 'nvim-autopairs'.setup {} end,
  }

  -- Check if nvim was started by firenvim. If so, we want to disable
  -- some plugins and tweak some settings, reason being that sometimes
  -- the size of the nvim window is _realy_ small (2-3 lines!)
  use 'gpanders/editorconfig.nvim'
  use { 'junegunn/fzf', event = "VimEnter" }
  use { 'junegunn/fzf.vim', event = "VimEnter" }
  use 'mhinz/vim-startify'
  use { 'tpope/vim-eunuch', event = "VimEnter" }
  -- vim-sensible sets things like ruler and laststatus which we don't want when we are using firenvim
  use 'tpope/vim-sensible'

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

  use { 'ryanoasis/vim-devicons', event = 'VimEnter' }

  use {
    'preservim/nerdtree',
    cmd = { 'NERDTreeToggle', 'NERDTreeFind' },
    keys = { '<Bslash>f', '<Blash>t' },
    config = function()
      vim.cmd [[
          " nerdtree configuration
          let NERDTreeShowHidden = 1
          let NERDTreeShowLineNumbers = 1

          nnoremap \t :NERDTreeToggle<CR>
          nnoremap \f :NERDTreeFind<CR>

          fun! s:QuitIfNERDTreeIsOnlyThingOpen()
            if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree())
              quit
            endif
          endfun

          aug fred#nerdtree
            au!
            au BufEnter * call s:QuitIfNERDTreeIsOnlyThingOpen()
          aug end
        ]]
    end
  }

  -- use {
  --   'vim-airline/vim-airline',
  --   config = function() require 'cfg.plugins.airline' end,
  -- }

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
    cmd = "Telescope",
    keys = "<space>f",
    config = function() require 'cfg.plugins.telescope' end
  }

  use {
    'fatih/vim-go',
    ft = { 'go', 'gomod' },
    config = function() require 'cfg.plugins.go' end
  }

  use {
    'junegunn/limelight.vim',
    event = 'VimEnter',
  }

  use {
    'norcalli/nvim-colorizer.lua',
    event = 'VimEnter',
    config = function() require "colorizer".setup() end
  }

  use {
    'iamcco/markdown-preview.nvim',
    run = function() vim.fn['mkdp#util#install']() end,
    ft = { 'markdown' },
    setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    event = 'VimEnter',
    config = function() require 'cfg.plugins.treesitter' end,
  }

  use {
    'glacambre/firenvim',
    event = 'VimEnter',
    run = function() vim.fn['firenvim#install'](0) end,
    config = function() require('cfg.plugins.firenvim') end,
  }

  use {
    'rcarriga/nvim-notify',
    event = 'VimEnter',
    config = function() vim.notify = require('notify').notify end,
  }

  use { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-emoji', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-nvim-lsp-signature-help', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-path', after = 'nvim-cmp' }
  use { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' }

  use {
    'nvim-lualine/lualine.nvim',
    config = function()
      require 'lualine'.setup {
        options = { theme = 'onedark' },
        tabline = {
          lualine_b = { 'buffers' },
        }
      }
    end,
    requires = { 'kyazdani42/nvim-web-devicons' }
  }
  -- use {
  --   'uga-rosa/cmp-dictionary',
  --   config = function()
  --     require("cmp_dictionary").setup {
  --       async = true,
  --       dic = {
  --         ["*"] = { "/usr/share/dict/words" },
  --       }
  --     }
  --   end,
  --   after = 'nvim-cmp',
  -- }


  -- nvim-cmp depends on cmp-nvim-lsp so since we are lazy loading this plugin
  -- it means that all of the plugins that depend on cmp-nvim-lsp will load
  -- lazily.
  use {
    'hrsh7th/cmp-nvim-lsp',
    event = {
      -- When we read a file we want nvim-cmp and lsp to initialize
      'BufRead',
      -- We use nvim-cmp for command completion too, so init completion
      -- when we want to use the nvim command line
      'CmdLineEnter'
    },
  }

  use {
    'onsails/lspkind.nvim',
    event = 'VimEnter',
  }

  use {
    'hrsh7th/nvim-cmp',
    config = function() require 'cfg.plugins.cmp' end,
    after = {
      'cmp-nvim-lsp',
      'lspkind.nvim',
      'nvim-autopairs',
    }
  }

  use {
    'kyazdani42/nvim-tree.lua',
    event = 'VimEnter',
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
  }

  use 'williamboman/nvim-lsp-installer'

  use {
    'neovim/nvim-lspconfig',
    config = function() require 'cfg.plugins.lsp' end,
    after = {
      'nvim-cmp',
      'nvim-lsp-installer',
    }
  }

  -- use {
  --   'rafamadriz/friendly-snippets',
  --   event = 'VimEnter',
  -- }

  use {
    'L3MON4D3/LuaSnip',
    after = {
      -- 'friendly-snippets',
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

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end, config = { profile = { enable = true, threshold = 1 } } })
