call plug#begin(stdpath('data') . '/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'lifepillar/vim-solarized8'
Plug 'fatih/vim-go'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ctrlpvim/ctrlp.vim'
Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tsandall/vim-rego'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'Chiel92/vim-autoformat'
call plug#end()

" vim configuration
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
set cursorline
let mapleader=' '

" jump to last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" fugitive configuration
nnoremap <C-g> :G<CR>

" vim-go configuration
autocmd Filetype go nmap <leader>t <Plug>(go-test)

" fzf.vim configuration
nnoremap <leader>f :Ag 
imap <c-x><c-f> <Plug>(fzf-complete-path)

"""""""""""""""""""""
" coc.nvim settings "
"""""""""""""""""""""

" if hidden is not set, TextEdit might fail.
set hidden
" Better display for messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=100
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
"inoremap <silent><expr> <TAB>
"      \ pumvisible() ? "\<C-n>" :
"      \ <SID>check_back_space() ? "\<TAB>" :
"      \ coc#refresh()
"inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
"
"function! s:check_back_space() abort
"  let col = col('.') - 1
"  return !col || getline('.')[col - 1]  =~# '\s'
"endfunction

" Use <CR> confirm completion
"inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm() : 
"  \"\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[c` and `]c` to navigate diagnostics
"nmap <silent> <leader>[c <Plug>(coc-diagnostic-prev)
"nmap <silent> <leader>]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
autocmd Filetype go map <silent> gd <Plug>(coc-definition)
autocmd Filetype go map <silent> gy <Plug>(coc-type-definition)
autocmd Filetype go map <silent> gi <Plug>(coc-implementation)
autocmd Filetype go map <silent> gr <Plug>(coc-references)

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>p  <Plug>(coc-format-selected)
nmap <leader>p  <Plug>(coc-format-selected)
" Show all diagnostics
nnoremap <silent> <leader>ca :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <leader>ce :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <leader>cc :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <leader>co :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <leader>cs :<C-u>CocList --interactive --auto-preview symbols<cr>
" Do default action for next item.
nnoremap <silent> <leader>cj :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <leader>ck :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <leader>cp :<C-u>CocListResume<CR>

" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0

" nerdtree configuration
let NERDTreeShowHidden = 1
let NERDTreeShowLineNumbers = 1
nnoremap <silent><leader>tt :NERDTreeToggle<CR>
nnoremap <silent><leader>tf :NERDTreeFind<CR>

" airline configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = 'base16_solarized'
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" ctrlp.vim configuration
let g:ctrlp_show_hidden = 1

" vim-rego configuration
let g:formatdef_rego = '"opa fmt"'
let g:formatters_rego = ['rego']
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
au BufWritePre *.rego Autoformat

" Various mappings
nnoremap <silent><F10> :qa!<CR>
nnoremap <silent><C-j> :tabnext<CR>
nnoremap <silent><C-k> :tabprevious<CR>
nnoremap <silent><C-l> :bnext<CR>
nnoremap <silent><C-h> :bprevious<CR>

"""""""""""""""
" colorscheme "
"""""""""""""""
set termguicolors " Enables 24-bit RGB color in the Terminal UI
set background=dark
let g:solarized_visibility = "low"
colorscheme solarized8
