" Use packer
lua require("duboisf.config.plugins")

" Check if we started nvim in pager mode
let g:pager_mode = get(g:, 'pager_mode', v:false)

" Check if nvim was started by firenvim. If so, we want to disable
" some plugins and tweak some settings, reason being that sometimes
" the size of the nvim window is _realy_ small (2-3 lines!)
let g:started_by_firenvim = get(g:, 'started_by_firenvim', v:false)

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

" Try to make nvim optimal when we only have an nvim window that's just 2-3
" lines high.
if exists("g:started_by_firenvim")
  " Never show the status line
  set laststatus=0
  " Don't show the line and column of the cursor position
  set noruler
  " Don't show the last command in the last line
  set noshowcmd
  " Don't show the current mode (insert, visual, etc.)
  set noshowmode
endif

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

" fugitive configuration
" Open :G in a maximized window
nnoremap <leader>g :G<CR>

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

" vim-go configuration
aug fred#go
  au!
  au Filetype go nmap <leader>t <Plug>(go-test)
  fu s:GoSettings()
    nmap <leader>tt <Plug>(go-test)
    nmap <leader>tf <Plug>(go-test-func)
    nmap <c-^>      <Plug>(go-alternate-edit)
    nmap <leader>tc <Cmd>GoCoverage<CR>
    command! -bang A call go#alternate#Switch(<bang>0, 'edit')
    command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
    command! -bang AS call go#alternate#Switch(<bang>0, 'split')
  endfu
  au Filetype go call s:GoSettings()
  au BufRead,BufNewFile */helm/templates/*.yaml set syntax=gohtmltmpl
aug end

" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0
let g:go_code_completion_enabled = 0
let g:go_gopls_enabled = 0
let g:go_doc_keywordprg_enabled = 0
" disable highlighting, we use tree-sitter
let g:go_highlight_string_spellcheck = 0
let g:go_highlight_format_strings = 0
let g:go_highlight_diagnostic_errors = 0
let g:go_highlight_diagnostic_errors = 0
let g:go_highlight_diagnostic_warnings = 0
" Don't use vim-go to format file on save, we use lsp to do this
let g:go_fmt_autosave = 0
let g:go_imports_autosave = 0

if g:pager_mode == v:false

  " prettier config
  let g:neoformat_try_node_exe = 1

  """""""""""""""""""""""""""
  " vim-grammarous settings "
  """""""""""""""""""""""""""
  nmap <leader>mo <Plug>(grammarous-open-info-window)

  """"""""""""""""""""""""""
  " vim-terraform settings "
  """"""""""""""""""""""""""
  let g:terraform_fmt_on_save=1

endif

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

" dispatch configuration
" disable all mappings, they are interfering with NERDTree's m mapping
let g:dispatch_no_maps = 1

" vim-rego configuration
let g:formatdef_rego = '"opa fmt"'
let g:formatters_rego = ['rego']
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0

aug fred#rego
  au!
  au BufWritePre *.rego Autoformat
aug end

"""""""""""""""""""""
" Misc autocommands "
"""""""""""""""""""""

au TextYankPost * lua vim.highlight.on_yank { higroup="IncSearch", timeout=300, on_visual=true }

colorscheme one
set background=dark
hi clear Search
hi default Search gui=reverse guifg=#ff6d00

" vim: sts=2 sw=2 ts=2 et
