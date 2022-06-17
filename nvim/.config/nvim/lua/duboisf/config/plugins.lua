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

-- Check if nvim was started by firenvim. If so, we want to disable
-- some plugins and tweak some settings, reason being that sometimes
-- the size of the nvim window is _realy_ small (2-3 lines!)
local startedByFirevim = vim.g.started_by_firenvim

local pagerMode = vim.g.pager_mode

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'justinmk/vim-sneak',
    'michaeljsmith/vim-indent-object',
    'simrat39/symbols-outline.nvim',
    'tpope/vim-commentary',
    'tpope/vim-repeat',
    'tpope/vim-surround',
    'tpope/vim-unimpaired',
    'windwp/nvim-autopairs',
  }

  if not startedByFirevim then
    use {
      'editorconfig/editorconfig-vim',
      'hashivim/vim-terraform',
      'junegunn/fzf',
      'junegunn/fzf.vim',
      'mhinz/vim-startify',
      'ryanoasis/vim-devicons',
      'tpope/vim-dispatch',
      'tpope/vim-eunuch',
      'tpope/vim-fugitive',
      'tpope/vim-rhubarb',
      -- vim-sensible sets things like ruler and laststatus which we don't want when we are using firenvim
      'tpope/vim-sensible',
      'tsandall/vim-rego',
    }

    use 'preservim/nerdtree'

    use {
      'vim-airline/vim-airline',
      config = function() require 'duboisf.config.plugins.airline' end,
    }
  end

  use {
    'lewis6991/gitsigns.nvim',
    config = function() require 'duboisf.config.plugins.gitsigns' end,
  }

  use {
    -- Requires git, fzf, python3, ripgrep
    -- Optional bat(like cat but 10x nicer!), exa(like ls but nicer!)
    'nvim-telescope/telescope.nvim',
    disable = startedByFirevim,
    requires = {
      'kyazdani42/nvim-web-devicons',
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    },
    config = function() require 'duboisf.config.plugins.telescope' end
  }

  use {
    'fatih/vim-go',
    disable = pagerMode,
    config = function() require 'duboisf.config.plugins.go' end
  }

  use {
    'junegunn/limelight.vim',
    disable = pagerMode
  }

  use {
    'norcalli/nvim-colorizer.lua',
    config = function() require "colorizer".setup() end
  }

  use {
    'iamcco/markdown-preview.nvim',
    run = function() vim.fn['mkdp#util#install']() end,
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
    disable = startedByFirevim,
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

  use {
    'hrsh7th/nvim-cmp',
    event = "BufEnter",
    config = function()
      print("cmp")
      require 'duboisf.config.plugins.cmp'
    end,
    requires = {
      'onsails/lspkind.nvim',
      'hrsh7th/cmp-nvim-lsp'
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
    after = 'friendly-snippets',
    config = function() require 'duboisf.config.plugins.luasnip' end,
  }

  use {
    'rakr/vim-one',
    config = function ()
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
end)
