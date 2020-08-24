" Check if nvim was started by firenvim. If so, we want to disable
" some plugins and tweak some settings, reason being that sometimes
" the size of the nvim window is _realy_ small (2-3 lines!)
let g:started_by_firenvim = get(g:, 'started_by_firenvim', v:false)

" Check if we started nvim in pager mode
let g:pager_mode = get(g:, 'pager_mode', v:false)

call plug#begin(stdpath('data') . '/plugged')
Plug 'Chiel92/vim-autoformat'
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plug 'junegunn/limelight.vim'
Plug 'michaeljsmith/vim-indent-object'
if g:pager_mode == v:false
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'psliwka/vim-smoothie'
Plug 'rakr/vim-one' " this is a nice theme
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'justinmk/vim-sneak'

" Only load the following plugins if we are not using nvim inside chrome
if g:started_by_firenvim == v:false
  Plug 'airblade/vim-gitgutter'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'fatih/vim-go'
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'mhinz/vim-startify'
  Plug 'preservim/nerdtree'
  Plug 'ryanoasis/vim-devicons'
  Plug 'tpope/vim-dispatch'
  Plug 'tpope/vim-eunuch'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  " vim-sensible sets things like ruler and laststatus which we don't want
  " when we are using firenvim
  Plug 'tpope/vim-sensible'
  Plug 'tsandall/vim-rego'
  Plug 'vim-airline/vim-airline'
  Plug 'will133/vim-dirdiff'
  " Requires git, fzf, python3, ripgrep
  " Optional bat(like cat but 10x nicer!), exa(like ls but nicer!)
  Plug 'yuki-ycino/fzf-preview.vim', { 'branch': 'release', 'do': ':UpdateRemotePlugins' }
endif

call plug#end()

"""""""""""""""""""""
" vim configuration "
"""""""""""""""""""""
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

" tweak settings if we are using nvim as a pager, we know this because
" se set the pager_mode variable when we do
if g:pager_mode
  set nolist
  set nowrap
  " use q in normal mode to quit, like in less
  nnoremap q :q<CR>
endif

if exists('g:started_by_firenvim')
  aug fred#firenvim
    au!
    au BufEnter github.com_*.txt set filetype=markdown
  aug end
endif

" Try to make nvim optimal when we only have an nvim window that's just 2-3
" lines high.
if exists('g:started_by_firenvim')
  " Never show the status line
  set laststatus=0
  " Don't show the line and column of the cursor position
  set noruler
  " Don't show the last command in the last line
  set noshowcmd
  " Don't show the current mode (insert, visual, etc.)
  set noshowmode
endif

" Use the spacebar as the key for <leader> mappings
let mapleader=' '

" Miscellaneous mappings
nnoremap <F10> :qa!<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>s :w<CR>
nnoremap <leader>m <C-W>_
nnoremap <leader>= <C-W>=
nnoremap <leader>. 10<C-W>>
nnoremap <leader>, 10<C-W><
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

" tweak man mode
aug fred#man
  au!
  au Filetype man call s:TweakManSettings()
  fu s:TweakManSettings()
    set nocursorline
    set nocursorcolumn
    nnoremap f <C-f>
    nnoremap d <C-b>
  endfu
aug end

"########################
"# PLUGIN CONFIGURATION #
"########################

" nvim-treesitter configuration

lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
      enable = true,
  },
}
EOF

" editorconfig configuration
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" startify configuration
" don't change cwd when jumping to a file
let g:startify_change_to_dir = 0

" fugitive configuration
" Open :G in a maximized window
nnoremap <leader>g :G \| wincmd _<CR>

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
    " Not sure about using an abbreviation... should I use a snippet?
    abbreviate ane assert.Nil(t, err)
    nmap <leader>t <Plug>(go-test)
    command! -bang A call go#alternate#Switch(<bang>0, 'edit')
    command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
    command! -bang AS call go#alternate#Switch(<bang>0, 'split')
  endfu
  autocmd Filetype go call s:GoSettings()
aug end

" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0
" disable gopls as we are using coc-go
let g:go_gopls_enabled = 0
let g:go_doc_keywordprg_enabled = 0
" extra highlighting options
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
" Use goimports
let g:go_fmt_command = 'goimports'
let g:go_fmt_fail_silently = 1

" fzf.vim configuration
inoremap <expr> <c-x><c-f> fzf#vim#complete#path("fd -t f -H", fzf#wrap({'dir': expand('%:p:h')}))

" fzf-preview configuration
nnoremap <silent> <Leader>fr     <cmd>CocCommand fzf-preview.FromResources project_mru directory<CR>
nnoremap <silent> <Leader>fb     <cmd>CocCommand fzf-preview.Buffers<CR>
nnoremap <silent> <Leader>fB     <cmd>CocCommand fzf-preview.AllBuffers<CR>
nnoremap <silent> <Leader>fe     <cmd>CocCommand fzf-preview.DirectoryFiles<CR>
nnoremap <silent> <Leader>fo     <cmd>CocCommand fzf-preview.FromResources buffer project_mru<CR>
nnoremap <silent> <Leader>f/     <cmd>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort<CR>
nnoremap <silent> <Leader>fq     <cmd>CocCommand fzf-preview.QuickFix<CR>
nnoremap <silent> <Leader>fl     <cmd>CocCommand fzf-preview.LocationList<CR>
nnoremap <silent> <Leader>f*     :<C-U>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
nnoremap <silent> <Leader>fd     :<C-U>CocCommand fzf-preview.DirectoryFiles <C-R>=expand('%:h')<CR><CR>
nnoremap          <Leader>ff     :<C-U>CocCommand fzf-preview.ProjectGrep<Space>
nnoremap <silent> <Leader>fs     :<C-U>CocCommand fzf-preview.ProjectGrep <C-r>=expand('<cword>')<CR><CR>
xnoremap          <Leader>fs     "sy:<C-U>CocCommand fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"<CR>
let g:fzf_preview_command = 'bat --color=always --theme="Solarized (dark)" --style=numbers,changes {-1}'
let g:fzf_preview_directory_files_command = 'fd . --type=file --hidden'
let g:fzf_preview_filelist_postprocess_command = 'xargs -d "\n" exa --color=always' " Use exa
let g:fzf_preview_fzf_preview_window_option = 'up:30%'
let g:fzf_preview_grep_cmd = "rg --line-number --hidden --no-heading --glob='!.git'"
let g:fzf_preview_lines_command = 'bat --color=always --theme="Solarized (dark)" --style=numbers,changes'
let g:fzf_preview_use_dev_icons = 1

if g:pager_mode == v:false

  """""""""""""""""""""
  " coc.nvim settings "
  """""""""""""""""""""
  " let g:node_client_debug = 1
  " let g:coc_node_args = ['--nolazy', '--inspect-brk=6045']
  let g:coc_global_extensions = [
  \   'coc-dictionary',
  \   'coc-emoji',
  \   'coc-fzf-preview',
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
  nnoremap <silent> <leader>od :<C-u>CocList diagnostics<cr>
  " Manage extensions
  nnoremap <silent> <leader>oe :<C-u>CocList extensions<cr>
  " Show commands
  nnoremap <silent> <leader>oy :<C-u>CocList commands<cr>
  " Find symbol of current document
  nnoremap <silent> <leader>oo :<C-u>CocList outline<cr>
  " Search workspace symbols
  nnoremap <silent> <leader>oi :<C-u>CocList --interactive --auto-preview symbols<cr>
  " Do default action for next item.
  nnoremap <silent> <leader>cj :<C-u>CocNext<CR>
  " Do default action for previous item.
  nnoremap <silent> <leader>ck :<C-u>CocPrev<CR>
  " Resume latest coc list
  nnoremap <silent> <leader>cp :<C-u>CocListResume<CR>

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

" airline configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

fu FredTreesitterStatus()
  let l:status = nvim_treesitter#statusline(100)
  if l:status ==# "null"
    return ""
  else
    return "🌳 " . l:status
  endif
endfu

fu s:airline_treesitter_init()
  if exists("*airline#parts#define_function")
    call airline#parts#define_function('treesitter-status', 'FredTreesitterStatus')
    let g:airline_section_x = airline#section#create_right(['bookmark', 'tagbar', 'vista', 'gutentags', 'grepper', 'treesitter-status', 'filetype'])
  endif
endfu

aug fred#airline
  au!
  au User AirlineAfterInit call s:airline_treesitter_init()
aug end

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

"#######################
"# THEME CONFIGURATION #
"#######################

set termguicolors " Enables 24-bit RGB color in the Terminal UI
set background=dark
colorscheme one

" tweaks to theme
hi clear Search
hi default Search gui=reverse guifg=#ff6d00

" Modify coc CursorHold highlight color
hi default CocHighlightText guibg=#4d1e0a
hi default link CocHighlightRead   CocHighlightText
hi default link CocHighlightWrite  CocHighlightText

" vim: sts=2 sw=2 ts=2 et
