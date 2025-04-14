vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup("duboisf.terminal", { clear = true }),
  pattern = '*',
  callback = function()
    -- disable mini.indentscope, it screws up the terminal display
    vim.b.miniindentscope_disable = true
  end,
})
