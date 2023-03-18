return {
  'tsandall/vim-rego',
  ft = { 'rego' },
  config = function()
    vim.cmd [[
      " vim-rego configuration
      let g:formatdef_rego = '"opa fmt"'
      let g:formatters_rego = ['rego']
      let g:autoformat_autoindent = 0
      let g:autoformat_retab = 0
    ]]
  end
}
