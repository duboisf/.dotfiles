call plug#begin(stdpath('data') . '/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-dispatch'
Plug 'lifepillar/vim-solarized8'
Plug 'romainl/flattened'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ctrlpvim/ctrlp.vim'
Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'sheerun/vim-polyglot'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'tsandall/vim-rego'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
"Plug 'Chiel92/vim-autoformat'
Plug 'mhinz/vim-startify'
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
set cursorcolumn
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
set dictionary+=/usr/share/dict/american-english
" Remove = from isfname so that completing a filename with <C-x><C-f>
" works even in an assignment like SOME_VAR=/foo/bar. The side effect of this
" will be that gf won't work with filenames with = in them... I don't think
" this will cause a lot of problems...
set isfname-==

let mapleader=' '
" jump to last position when reopening a file
aug fred#jump_to_last_position
  au!
  au Filetype gitcommit let b:disable_jump_to_last_position = 1
  au BufReadPost * call s:JumpToLastPositionWhenReopeningBuffer()
  fun s:JumpToLastPositionWhenReopeningBuffer()
    if exists('b:disable_jump_to_last_position')
      return
    endif
    if line("'\"") > 0 && line("'\"") <= line("$")
      exe "normal! g`\""
    endif
  endfun
aug end

" tweak man mode
aug fred#man
  au!
  au Filetype man call s:TweakManSettings()
  fu s:TweakManSettings()
    set nocursorline
    set nocursorcolumn
  endfu
aug end

" fugitive configuration
nnoremap <leader>g :G \| wincmd _<CR>

" vim-go configuration
"aug fred#go
"  au!
"  au Filetype go nmap <leader>t <Plug>(go-test)
"aug end
"
"" disable vim-go :GoDef short cut (gd)
"" this is handled by LanguageClient [LC]
"let g:go_def_mapping_enabled = 0
"let g:go_doc_keywordprg_enabled = 0

" fzf.vim configuration
nnoremap <leader>f :Rg<CR>
inoremap <expr> <c-x><c-f> fzf#vim#complete#path("fd -t f -H", fzf#wrap({'dir': expand('%:p:h')}))

"""""""""""""""""""""
" coc.nvim settings "
"""""""""""""""""""""
" let g:node_client_debug = 1
" let g:coc_node_args = ['--nolazy', '--inspect-brk=6045']
let g:coc_global_extensions = [
\   'coc-emoji',
\   'coc-go',
\   'coc-json',
\   'coc-snippets',
\   'coc-word',
\   'coc-yaml'
\ ]

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
inoremap <silent><expr> <TAB>
  \ pumvisible()
    \ ? coc#_select_confirm()
    \ : coc#expandableOrJumpable()
      \ ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>"
      \ : <SID>check_back_space()
        \ ? "\<TAB>"
        \ : coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

aug fred#coc
  au!
  " Highlight the symbol and its references when holding the cursor.
  au CursorHold * silent call CocActionAsync('highlight')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  " Remap keys for gotos
  fu s:GoCocMappings()
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)
  endfu
  au Filetype go call s:GoCocMappings()
aug end

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

nmap <leader>rc <Plug>(coc-float-hide)
nmap <leader>ol <Plug>(coc-open-link)

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

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

" nerdtree configuration
let NERDTreeShowHidden = 1
let NERDTreeShowLineNumbers = 1
nnoremap <silent><leader>tt :NERDTreeToggle<CR>
nnoremap <silent><leader>tf :NERDTreeFind<CR>
aug fred#nerdtree
  au!
  au BufEnter * call s:QuitIfNERDTreeIsOnlyThingOpen()
  fun! s:QuitIfNERDTreeIsOnlyThingOpen()
    if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree())
      quit
    endif
  endfun
aug end

" airline configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = 'base16_solarized'
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" ctrlp.vim configuration
let g:ctrlp_show_hidden = 1
let g:ctrlp_working_path_mode = 'ra'

" vim-rego configuration
let g:formatdef_rego = '"opa fmt"'
let g:formatters_rego = ['rego']
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0

aug fred#rego
  au!
  au BufWritePre *.rego Autoformat
aug end

" highlight comments in jsonc files (json with comments, used by coc
" config/vscode)
aug fred#json
  au!
  au FileType json syntax match Comment +\/\/.\+$+
aug end

" Various mappings
nnoremap <F10> :qa!<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>s :w<CR>
nnoremap <leader>m <C-W>_
nnoremap <leader>= <C-W>=
nnoremap <leader>. 10<C-W>>
nnoremap <leader>, 10<C-W><
nnoremap <A-f> <C-f>
nnoremap <A-b> <C-b>

"""""""""""""""
" colorscheme "
"""""""""""""""
set termguicolors " Enables 24-bit RGB color in the Terminal UI
set background=dark
let g:solarized_visibility = "low"
colorscheme solarized8
" vim: sts=2 sw=2 ts=2 et
