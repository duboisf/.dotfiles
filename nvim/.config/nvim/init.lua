local fn = vim.fn

-- define a bunch of autocommands to help with lazy loading
local group = vim.api.nvim_create_augroup('duboisf', { clear = true })

local autocmd = function(events, callback)
  if type(events) == 'string' then
    events = { events }
  end
  vim.api.nvim_create_autocmd(events, {
    group = group,
    pattern = "*",
    callback = callback
  })
end

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  desc = "Run packer.compile() when any plugin lua config file gets saved",
  pattern = "*/.config/nvim/init.lua",
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

-- jump to last position when reopening a file
autocmd('Filetype', function() vim.b.disable_jump_to_last_position = 1 end)

-- au Filetype gitcommit let b:disable_jump_to_last_position = 1
-- au BufReadPost * call s:JumpToLastPositionWhenReopeningBuffer()
-- fun s:JumpToLastPositionWhenReopeningBuffer()
--   if exists('b:disable_jump_to_last_position')
--     return
--   endif
--   if line("'\"") > 0 && line("'\"") <= line("$")
--     exe "normal! g`\""
--   endif
-- endfun
-- aug end
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
  use { 'editorconfig/editorconfig-vim', event = "VimEnter" }
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
    keys = "<space>g",
    config = function()
      -- Open :G in a maximized window
      vim.cmd 'nnoremap <leader>g :G<CR>'
    end,
  }

  use { 'tpope/vim-rhubarb', after = 'vim-fugitive' }

  use { 'ryanoasis/vim-devicons', event = 'VimEnter' }

  use {
    'preservim/nerdtree',
    cmd = { 'NERDTreeToggle', 'NERDTreeFind' },
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
    event = 'User InGitRepo',
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
    command = "Telescope",
    keys = "<space>f",
    config = function() require 'duboisf.config.plugins.telescope' end
  }

  use {
    'fatih/vim-go',
    ft = { 'go', 'gomod' },
    config = function() require 'duboisf.config.plugins.go' end
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
    config = function() require 'duboisf.config.plugins.treesitter' end,
  }

  use {
    'glacambre/firenvim',
    event = 'VimEnter',
    run = function() vim.fn['firenvim#install'](0) end,
    config = function() require('duboisf.config.plugins.firenvim') end,
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
    event = 'VimEnter',
  }

  use {
    'hrsh7th/nvim-cmp',
    config = function() require 'duboisf.config.plugins.cmp' end,
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
    config = function() require 'duboisf.config.plugins.lsp' end,
    after = {
      'nvim-cmp',
      'nvim-lsp-installer',
    }
  }

  use {
    'rafamadriz/friendly-snippets',
    event = 'VimEnter',
  }

  use {
    'L3MON4D3/LuaSnip',
    after = { 'friendly-snippets', 'nvim-cmp' },
    config = function() require 'duboisf.config.plugins.luasnip' end,
  }

  use 'rakr/vim-one'

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end, config = { profile = { enable = true, threshold = 1 } } })

vim.cmd [[
" Check if we started nvim in pager mode
let g:pager_mode = get(g:, 'pager_mode', v:false)

"""""""""""""""""""""
" vim configuration "
"""""""""""""""""""""
set termguicolors " Enables 24-bit RGB color in the Terminal UI
set mouse=a
set relativenumber
set number
set textwidth=0
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set encoding=utf-8
set listchars=tab:→\ ,trail:·,eol:↩
set list
set scrolloff=0
set cursorline
if !&diff
  set cursorcolumn
endif
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
set dictionary+=/usr/share/dict/american-english
" Remove = from isfname so that completing a filename with <C-x><C-f>
" works even in an assignment like SOME_VAR=/foo/bar. The side effect of this
" will be that gf won't work with filenames with = in them... I don't think
" this will cause a lot of problems...
set isfname-==
" if hidden is not set, TextEdit might fail.
set hidden
" Don't show the current mode (insert, visual, etc.)
set noshowmode
" Better display for messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=100
" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns. We set it on BufRead, otherwise on nvim startup 
set signcolumn=yes:2

" show interactive substitute
set inccommand=nosplit

if exists('g:started_by_firenvim')
  " Try to make nvim optimal when we only have an nvim window that's just 2-3 lines high
  " Never show the status line
  set laststatus = 0
  " Don't show the line and column of the cursor position
  set noruler
  " Don't show the last command in the last line
  set noshowcmd
  " Don't show open tabs and buffers on the first line
  set showtabline = 0
endif

" tweak settings if we are using nvim as a pager, we know this because
" we set the pager_mode variable when we do
if g:pager_mode
  set nolist
  set nowrap
  " use q in normal mode to quit, like in less
  nnoremap q :q<CR>
endif

" Use the spacebar as the key for <leader> mappings
let mapleader=' '

" Miscellaneous mappings
nnoremap <leader>q :q<CR>
nnoremap <leader>s :w<CR>
nnoremap <leader>b :bd<CR>
nnoremap <leader>m <C-W>_
nnoremap <leader>= <C-W>=
nnoremap <leader>. 10<C-W>>
nnoremap <leader>, 10<C-W><
" Move selection up or down
xnoremap <C-Up> xkP`[V`]
xnoremap <C-Down> xp`[V`]
" Toggle wrap
nnoremap <leader>w :set wrap!<CR>
" Toggle paste
nnoremap <leader>p :set paste!<CR>
" Yank highlighted selection in visual mode to clipboard
vnoremap <leader>y "+y
" Yank highlighted lines in visual mode to clipboard
vnoremap <leader>Y "+Y
" Tab and Shift-Tab keys cycle through buffers
nnoremap <Tab> :bn<CR>
nnoremap <S-Tab> :bp<CR>

" tweak man mode
aug fred#man
  au!
  au Filetype man call s:TweakManSettings()
  fu s:TweakManSettings()
    echo "TweakManSettings"
    set nocursorline
    set nocursorcolumn
    nnoremap f <C-f>
    nnoremap d <C-b>
  endfu
aug end

"########################
"# PLUGIN CONFIGURATION #
"########################

" editorconfig configuration
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" startify configuration
" don't change cwd when jumping to a file
let g:startify_change_to_dir = 0

let g:startify_lists = [
      \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
      \ { 'type': 'files',     'header': ['   MRU']            },
      \ ]

" firenvim configuration
let g:firenvim_config = {
    \ 'globalSettings': {
        \ 'alt': 'all',
    \  },
    \ 'localSettings': {
        \ '.*': {
            \ 'cmdline': 'firenvim',
            \ 'priority': 0,
            \ 'selector': 'textarea',
            \ 'takeover': 'never',
        \ },
    \ }
\ }

"""""""""""""""""""""
" Misc autocommands "
"""""""""""""""""""""

let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1

au TextYankPost * lua vim.highlight.on_yank { higroup="IncSearch", timeout=300, on_visual=true }

colorscheme one
set background=dark
hi clear Search
hi default Search gui=reverse guifg=#ff6d00

]]

-- vim: sts=2 sw=2 ts=2 et
