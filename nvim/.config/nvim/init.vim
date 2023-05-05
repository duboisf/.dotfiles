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
nnoremap <silent><leader>s :silent w<CR>
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

" tweak man mode
aug fred#man
  au!
  au Filetype man call s:TweakManSettings()
  fu s:TweakManSettings()
    echo "TweakManSettings"
    set nocursorline
    set nocursorcolumn
    nnoremap <buffer><silent>f <C-f>
    nnoremap <buffer><silent>d <C-b>
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
endif

" vim: sts=2 sw=2 ts=2 et
