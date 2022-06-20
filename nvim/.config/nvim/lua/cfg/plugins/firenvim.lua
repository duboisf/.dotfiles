local group = vim.api.nvim_create_augroup("fred#firenvim", {})
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  pattern = "github.com_*.txt",
  desc = "Set filetype to markdown when using firenvim on github",
  command = "set filetype=markdown",
})

