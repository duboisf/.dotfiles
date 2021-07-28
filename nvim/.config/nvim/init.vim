" Check if nvim was started by firenvim. If so, we want to disable
" some plugins and tweak some settings, reason being that sometimes
" the size of the nvim window is _realy_ small (2-3 lines!)
let g:started_by_firenvim = get(g:, 'started_by_firenvim', v:false)

" Check if we started nvim in pager mode
let g:pager_mode = get(g:, 'pager_mode', v:false)

let g:enable_coc = get(g:, 'enable_coc', v:false)

call plug#begin(stdpath('data') . '/plugged')

" Always load the following plugins
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'norcalli/nvim-colorizer.lua'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'rakr/vim-one' " this is a nice theme


" Only load the following plugins if we're not using nvim as a pager
if g:pager_mode == v:false
  Plug 'Chiel92/vim-autoformat'
  " Plug 'ctrlpvim/ctrlp.vim'
  Plug 'fatih/vim-go'
  Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
  Plug 'golang/vscode-go'
  Plug 'hrsh7th/nvim-compe'
  Plug 'hrsh7th/vim-vsnip'
  " Plug 'junegunn/limelight.vim'
  " Plug 'justinmk/vim-sneak'
  " Plug 'michaeljsmith/vim-indent-object'
  if g:enable_coc == v:true
      Plug 'neoclide/coc.nvim', {'branch': 'release'}
  endif
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-treesitter/playground'
  " Plug 'psliwka/vim-smoothie'
  Plug 'rhysd/vim-grammarous'
  " Plug 'SirVer/ultisnips'
  Plug 'simrat39/symbols-outline.nvim'
  " Plug 'towolf/vim-helm'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-unimpaired'
  " Plug 'windwp/nvim-autopairs'
endif

" Only load the following plugins if we are not using nvim inside chrome
if g:started_by_firenvim == v:false
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'hashivim/vim-terraform'
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'lewis6991/gitsigns.nvim', {'branch': 'main'}
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
  " Plug 'will133/vim-dirdiff'
  " Requires git, fzf, python3, ripgrep
  " Optional bat(like cat but 10x nicer!), exa(like ls but nicer!)
  " Plug 'yuki-ycino/fzf-preview.vim', { 'branch': 'release/rpc' }
  " telescope has the following dependencies
  Plug 'kyazdani42/nvim-web-devicons'
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
endif

call plug#end()

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
set scrolloff=5
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

if g:pager_mode == v:false
  lua require('duboisf/config')
end

" lsp configuration
augroup lsp
  autocmd!
  autocmd BufWritePre * lua require'duboisf.config.lsp'.safe_formatting_sync()
augroup end

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
aug end

" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0
" disable gopls as we are using coc-go
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

" fzf.vim configuration
inoremap <expr> <c-x><c-f> fzf#vim#complete#path("fd -t f -H", fzf#wrap({'dir': expand('%:p:h')}))

" fzf-preview configuration
" nnoremap <silent> <Leader>fr      <cmd>FzfPreviewFromResourcesRpc project_mru directory<CR>
" nnoremap <silent> <Leader>fb      <cmd>FzfPreviewBuffersRpc<CR>
" nnoremap <silent> <Leader>fB      <cmd>FzfPreviewAllBuffersRpc<CR>
" nnoremap <silent> <Leader>fe      <cmd>FzfPreviewDirectoryFilesRpc<CR>
" nnoremap <silent> <Leader>fo      <cmd>FzfPreviewFromResourcesRpc buffer project_mru<CR>
" nnoremap <silent> <Leader>f/      <cmd>FzfPreviewLinesRpc --add-fzf-arg=--no-sort<CR>
" nnoremap <silent> <Leader>fq      <cmd>FzfPreviewQuickFixRpc<CR>
" nnoremap <silent> <Leader>fl      <cmd>FzfPreviewLocationListRpc<CR>
" nnoremap <silent> <Leader>f*     :<C-U>FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
" nnoremap <silent> <Leader>fd     :<C-U>FzfPreviewDirectoryFilesRpc <C-R>=expand('%:h')<CR><CR>
" nnoremap          <Leader>ff     :<C-U>FzfPreviewProjectGrepRpc<Space>
" nnoremap <silent> <Leader>fs     :<C-U>FzfPreviewProjectGrepRpc <C-r>=expand('<cword>')<CR><CR>
" xnoremap          <Leader>fs     "sy:<C-U>FzfPreviewProjectGrepRpc<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"<CR>
" let g:fzf_preview_command = 'bat --color=always --theme="Solarized (dark)" --style=numbers,changes {-1}'
" let g:fzf_preview_directory_files_command = 'fd . --type=file --hidden'
" let g:fzf_preview_filelist_postprocess_command = 'xargs -d "\n" exa --color=always' " Use exa
" let g:fzf_preview_fzf_preview_window_option = 'up:30%'
" let g:fzf_preview_grep_cmd = "rg --line-number --hidden --no-heading --glob='!.git'"
" let g:fzf_preview_lines_command = 'bat --color=always --theme="Solarized (dark)" --style=numbers,changes'
" let g:fzf_preview_use_dev_icons = 1

if g:pager_mode == v:false

  """""""""""""""""""""""""""
  " vim-grammarous settings "
  """""""""""""""""""""""""""
  nmap <leader>mo <Plug>(grammarous-open-info-window)

  """"""""""""""""""""""""""
  " vim-terraform settings "
  """"""""""""""""""""""""""
  let g:terraform_fmt_on_save=1

  if g:enable_coc == v:true
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
    set signcolumn=yes:3

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
        nmap <silent> gn <Plug>(coc-rename)
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

" telescope configuration
nnoremap <silent> <leader>fe  <cmd>lua require('duboisf.config.telescope').project_files()<cr>
nnoremap <silent> <leader>fd  <cmd>lua require('duboisf.config.telescope').cwd_files()<cr>
nnoremap <silent> <leader>fs  <cmd>Telescope lsp_document_symbols<cr>
nnoremap <silent> <leader>fw  <cmd>Telescope lsp_dynamic_workspace_symbols<cr>
nnoremap <silent> <leader>f*  <cmd>Telescope current_buffer_fuzzy_find<cr>
nnoremap <silent> <leader>fgg <cmd>Telescope live_grep cwd=%:h<cr>
nnoremap <silent> <leader>fgw <cmd>Telescope live_grep<cr>
nnoremap <silent> <leader>fb  <cmd>Telescope buffers<cr>
nnoremap <silent> <leader>fh  <cmd>Telescope help_tags<cr>
nnoremap <silent> <leader>fr  <cmd>Telescope registers<cr>
nnoremap <silent> <leader>fm  <cmd>Telescope keymaps<cr>

" compe configuration
inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

" vsnip configuration
"
" NOTE: You can use other key to expand snippet.

" Expand or jump
imap <expr> <C-j>   vsnip#available( 1)  ? '<Plug>(vsnip-jump-next)' : '<C-l>'
smap <expr> <C-j>   vsnip#available( 1)  ? '<Plug>(vsnip-jump-next)' : '<C-l>'
imap <expr> <C-k>   vsnip#available(-1)  ? '<Plug>(vsnip-jump-prev)' : '<C-l>'
smap <expr> <C-k>   vsnip#available(-1)  ? '<Plug>(vsnip-jump-prev)' : '<C-l>'

" Jump forward or backward
" imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
" smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
" imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
" smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
" nmap        s   <Plug>(vsnip-select-text)
" xmap        s   <Plug>(vsnip-select-text)
" nmap        S   <Plug>(vsnip-cut-text)
" xmap        S   <Plug>(vsnip-cut-text)

"#######################
"# THEME CONFIGURATION #
"#######################

set background=dark
colorscheme one

" tweaks to theme
hi clear Search
hi default Search gui=reverse guifg=#ff6d00

" used to display git blames with gitsigns
hi FloatBorder guifg=white guibg=#333841

hi LspReferenceText guibg=#4d1e0a
hi LspReferenceRead guibg=#1d1e0a
hi LspReferenceWrite guibg=#fd1e0a

hi LspDiagnosticsVirtualTextError guifg=Red ctermfg=Red
hi LspDiagnosticsVirtualTextWarning guifg=Yellow ctermfg=Yellow
hi LspDiagnosticsVirtualTextInformation guifg=White ctermfg=White
hi LspDiagnosticsVirtualTextHint guifg=White ctermfg=White

hi LspDiagnosticsUnderlineError guifg=Red ctermfg=NONE cterm=undercurl gui=undercurl
hi LspDiagnosticsUnderlineWarning guifg=Yellow ctermfg=NONE cterm=underline gui=underline
hi LspDiagnosticsUnderlineInformation guifg=NONE ctermfg=NONE cterm=underline gui=underline
hi LspDiagnosticsUnderlineHint guifg=Cyan ctermfg=NONE cterm=underline gui=underline

hi LspDiagnosticsFloatingError guifg=#E74C3C
hi LspDiagnosticsSignError guifg=#E74C3C

hi LspCodeLens guifg=Cyan

" vim: sts=2 sw=2 ts=2 et
