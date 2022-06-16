vim.cmd [[
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
]]
