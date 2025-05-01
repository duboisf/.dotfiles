" tweak settings if we are using nvim as a pager, we know this because
" we set the pager_mode variable when we do
if get(g:, 'pager_mode', 0)
  set nolist
  set nowrap
  " use q in normal mode to quit, like in less
  nnoremap <silent>q :q<CR>
endif
