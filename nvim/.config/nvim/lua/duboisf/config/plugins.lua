local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
end

local group = vim.api.nvim_create_augroup("duboisf#config#plugins", {})
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  desc = "Run packer.compile() when any plugin lua config file gets saved",
  pattern = "*/.config/*/duboisf/config/plugins.lua",
  command = "source <afile> | PackerCompile",
})
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "PackerCompileDone",
  callback = function() vim.notify("Compilation done 🎉", vim.log.levels.INFO, { title = "Packer" }) end,
})

function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(unpack(objects))
  return ...
end

require('packer').startup({function(use)
  use 'wbthomason/packer.nvim'

  use 'justinmk/vim-sneak'
  use 'michaeljsmith/vim-indent-object'
  use 'tpope/vim-commentary'
  use 'tpope/vim-repeat'
  use 'tpope/vim-surround'
  use 'tpope/vim-unimpaired'
  use 'windwp/nvim-autopairs'

  -- Check if nvim was started by firenvim. If so, we want to disable
  -- some plugins and tweak some settings, reason being that sometimes
  -- the size of the nvim window is _realy_ small (2-3 lines!)
  use { 'editorconfig/editorconfig-vim' }
  use { 'junegunn/fzf' }
  use { 'junegunn/fzf.vim' }
  use { 'mhinz/vim-startify' }
  use { 'tpope/vim-eunuch' }
  -- vim-sensible sets things like ruler and laststatus which we don't want when we are using firenvim
  use { 'tpope/vim-sensible' }

  use {
    'tsandall/vim-rego',
    ft = { 'rego' },
    config = function ()
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

  use { 'tpope/vim-rhubarb', after = 'vim-fugitive' }

  use { 'ryanoasis/vim-devicons' }

  use {
    'preservim/nerdtree',
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

  use {
    'vim-airline/vim-airline',
    config = function() require 'duboisf.config.plugins.airline' end,
  }

  use {
    'lewis6991/gitsigns.nvim',
    config = function() require 'duboisf.config.plugins.gitsigns' end,
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
    config = function() require 'duboisf.config.plugins.telescope' end
  }

  use {
    'fatih/vim-go',
    ft = { 'go', 'gomod' },
    config = function() require 'duboisf.config.plugins.go' end
  }

  use {
    'junegunn/limelight.vim',
  }

  use {
    'norcalli/nvim-colorizer.lua',
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
    config = function() require 'duboisf.config.plugins.treesitter' end,
  }

  use {
    'glacambre/firenvim',
    run = function() vim.fn['firenvim#install'](0) end,
    config = function() require('duboisf.config.plugins.firenvim') end,
  }

  use {
    'rcarriga/nvim-notify',
    config = function() vim.notify = require('notify').notify end,
  }

  use { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-emoji', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-nvim-lsp-signature-help', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-path', after = 'nvim-cmp' }
  use { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' }

  use {
    'uga-rosa/cmp-dictionary',
    config = function()
      require("cmp_dictionary").setup {
        async = true,
        dic = {
          ["*"] = { "/usr/share/dict/words" },
        }
      }
    end,
    after = 'nvim-cmp',
  }


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
  }

  use {
    'hrsh7th/nvim-cmp',
    config = function() print("cmp"); require 'duboisf.config.plugins.cmp' end,
    after = {
      'lspkind.nvim',
      'cmp-nvim-lsp',
    }
  }

  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
  }

  use 'williamboman/nvim-lsp-installer'

  use {
    'neovim/nvim-lspconfig',
    config = function() require 'duboisf.config.plugins.lsp' end,
    after = {
      'nvim-cmp',
      'nvim-lsp-installer',
    }
  }

  use 'rafamadriz/friendly-snippets'

  use {
    'L3MON4D3/LuaSnip',
    after = { 'friendly-snippets', 'nvim-cmp' },
    config = function() require 'duboisf.config.plugins.luasnip' end,
  }

  use {
    'rakr/vim-one',
    config = function()
      local c = vim.cmd
      c 'colorscheme one'
      c 'set background=dark'
      c 'hi clear Search'
      c 'hi default Search gui=reverse guifg=#ff6d00'
    end
  }

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end, config = { profile = { enable = true, threshold = 1 } } })
