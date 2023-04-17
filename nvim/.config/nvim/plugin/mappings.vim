" Useful map to move over a parenthesis that was injected by the autopairs plugin
imap <C-f> <C-o>l

" Alt-u changes the cwd of the current tab up one level (to the parent folder)
nmap <A-u> :tcd ..<CR>

" Alt-i either opens a popup with the current TreeSitter node or the current
" highlight group under the cursor
nnoremap <silent><A-i> :lua require('core.utils').inspect_highlight()<CR>
