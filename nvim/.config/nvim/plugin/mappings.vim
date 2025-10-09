" Miscellaneous mappings
nnoremap <silent><leader>q :q<CR>
nnoremap <silent><leader>s :silent w<CR>
nnoremap <silent><leader>x :bd<CR>
" Move selection up or down
xnoremap <silent><C-Up> xkP`[V`]
xnoremap <silent><C-Down> xp`[V`]
" Move current line up or down
nnoremap <silent><C-Up> ddkP
nnoremap <silent><C-Down> ddp
" Toggle wrap
nnoremap <silent>[w :set wrap<CR>
nnoremap <silent>]w :set nowrap<CR>
" Yank highlighted selection in visual mode to clipboard
vnoremap <silent><leader>y "+y
" Yank highlighted lines in visual mode to clipboard
vnoremap <silent><leader>Y "+Y
" Tab and Shift-Tab keys cycle through buffers
nnoremap <silent><Tab> :bn<CR>
nnoremap <silent><S-Tab> :bp<CR>

" Useful map to move over a parenthesis that was injected by the autopairs plugin
inoremap <C-l> <C-o>l

nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz

" In a terminal buffer, return to normal mode by pressing Esc
tmap <silent><Esc> <C-\><C-n>

" Useful map to move over a parenthesis that was injected by the autopairs plugin
imap <C-l> <Esc>la

" Change the cwd of the current tab up one level (to the parent folder)
nmap <A-u> lcd ..<CR>
