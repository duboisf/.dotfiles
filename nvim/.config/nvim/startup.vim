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
" show tabs, newlines and trailing spaces
set list
" specify the characters to use for tabs, trailing spaces and newlines
set listchars=tab:→\ ,trail:·,eol:↩
" minimum num of screenlines to keep aboe and below the cursor
set scrolloff=3
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

" always show signcolumns
set signcolumn=yes:2

" show interactive substitute
set inccommand=nosplit

" highlight lua code in .vim files
let g:vimsyn_embed = 'l'

" Don't show the last command in the last line
set noshowcmd

" use only 1 status line for all open windows
set laststatus=3

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
" Move current line up or down
nnoremap <C-Up> ddkP
nnoremap <C-Down> ddp
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

" in insert mode, make ctrl-e jump to the end of the line, staying in insert
" mode
inoremap <C-e> <C-O>$

" Navigate windows in any mode
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

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

au TextYankPost * lua vim.highlight.on_yank { higroup="IncSearch", timeout=300, on_visual=true }

" vim: sts=2 sw=2 ts=2 et
