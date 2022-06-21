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

" Don't show the last command in the last line
set noshowcmd

if exists('g:started_by_firenvim')
  " Try to make nvim optimal when we only have an nvim window that's just 2-3 lines high
  " Never show the status line
  set laststatus=0
  " Don't show the line and column of the cursor position
  set noruler
  " Don't show open tabs and buffers on the first line
  set showtabline=0
  " Reduce cmd lines to minimum. For now the min is 1 buf after
  " https://github.com/neovim/neovim/pull/16251 gets released the
  " min is going to be 0
  set cmdheight=1
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
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ { 'type': 'commands',  'header': ['   Commands']       },
      \ ]

"""""""""""""""""""""
" Misc autocommands "
"""""""""""""""""""""

" deactivate netrw
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1

au TextYankPost * lua vim.highlight.on_yank { higroup="IncSearch", timeout=300, on_visual=true }

" vim: sts=2 sw=2 ts=2 et
