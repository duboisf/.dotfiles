" Use the spacebar as the key for <leader> mappings
" This needs to be set _before_ loading lazy!
let mapleader=' '

" lazy.nvim sets loadplugins to false to control
" the whole loading process, capture it's value
" before calling lazy. I use a safe-nvim alias
" to disable loading all plugins when opening
" sensitive files like credentials.
let original_loadplugins = &loadplugins

lua pcall(require, 'cfg.lazy')

" Check if we started nvim in pager mode
let g:pager_mode = get(g:, 'pager_mode', v:false)

"""""""""""""""""""""
" vim configuration "
"""""""""""""""""""""

set clipboard=unnamed
" Enable 24-bit RGB color in the Terminal UI
set termguicolors
set mouse=a
set relativenumber
set number
set textwidth=0
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set encoding=utf-8
set nolist
" specify the characters to use for tabs and trailing spaces
set listchars=tab:→\ ,trail:·
set cursorline
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
set dictionary+=/usr/share/dict/american-english
" Remove = from isfname so that completing a filename with <C-x><C-f>
" works even in an assignment like SOME_VAR=/foo/bar. The side effect of this
" will be that gf won't work with filenames with = in them... I don't think
" this will cause a lot of problems...
set isfname-==
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
" Prevent long, single lines from slowing down the redraw speed. In my case
" this often happens when viewing kubernetes resources as the
" kubectl.kubernetes.io/last-applied-configuration is a single line that
" contains the whole previous version of the resource.
set synmaxcol=300
" highlight lua code in .vim files
let g:vimsyn_embed = 'l'

" Don't show the last command in the last line
set noshowcmd

" use only 1 status line for all open windows
set laststatus=3

" tweak settings if we are using nvim as a pager, we know this because
" we set the pager_mode variable when we do
if g:pager_mode
  set nolist
  set nowrap
  " use q in normal mode to quit, like in less
  nnoremap <silent>q :q<CR>
endif

" Miscellaneous mappings
nnoremap <silent><leader>q :q<CR>
nnoremap <silent><leader>s :w<CR>
nnoremap <silent><leader>b :bd<CR>
nnoremap <silent><leader>m <C-W>_
nnoremap <silent><leader>= <C-W>=
nnoremap <silent><leader>. 10<C-W>>
nnoremap <silent><leader>, 10<C-W><
" Move selection up or down
xnoremap <silent><C-Up> xkP`[V`]
xnoremap <silent><C-Down> xp`[V`]
" Move current line up or down
nnoremap <silent><C-Up> ddkP
nnoremap <silent><C-Down> ddp
" Toggle wrap
nnoremap <silent><leader>w :set wrap!<CR>
" Yank highlighted selection in visual mode to clipboard
vnoremap <silent><leader>y "+y
" Yank highlighted lines in visual mode to clipboard
vnoremap <silent><leader>Y "+Y
" Tab and Shift-Tab keys cycle through buffers
nnoremap <silent><Tab> :bn<CR>
nnoremap <silent><S-Tab> :bp<CR>

" in insert mode, make ctrl-e jump to the end of the line, staying in insert
" mode
inoremap <silent><C-e> <C-O>$

" Navigate windows in any mode
tnoremap <silent><A-h> <C-\><C-N><C-w>h
tnoremap <silent><A-j> <C-\><C-N><C-w>j
tnoremap <silent><A-k> <C-\><C-N><C-w>k
tnoremap <silent><A-l> <C-\><C-N><C-w>l
inoremap <silent><A-h> <C-\><C-N><C-w>h
inoremap <silent><A-j> <C-\><C-N><C-w>j
inoremap <silent><A-k> <C-\><C-N><C-w>k
inoremap <silent><A-l> <C-\><C-N><C-w>l
nnoremap <silent><A-h> <C-w>h
nnoremap <silent><A-j> <C-w>j
nnoremap <silent><A-k> <C-w>k
nnoremap <silent><A-l> <C-w>l

" tweak man mode
aug fred#man
  au!
  au Filetype man call s:TweakManSettings()
  fu s:TweakManSettings()
    echo "TweakManSettings"
    set nocursorline
    set nocursorcolumn
    nnoremap <silent>f <C-f>
    nnoremap <silent>d <C-b>
  endfu
aug end

"########################
"# PLUGIN CONFIGURATION #
"########################

" editorconfig configuration
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

"""""""""""""""""""""
" Misc autocommands "
"""""""""""""""""""""

au TextYankPost * lua vim.highlight.on_yank { higroup="IncSearch", timeout=300, on_visual=true }

if ! original_loadplugins
  " when loading without plugins, use built-in colorscheme
  color habamax
else
  color onedark
endif

" vim: sts=2 sw=2 ts=2 et
