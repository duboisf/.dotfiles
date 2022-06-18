local group = vim.api.nvim_create_augroup("fred#firenvim", {})
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  pattern = "github.com_*.txt",
  desc = "Set filetype to markdown when using firenvim on github",
  command = "set filetype=markdown",
})

-- Try to make nvim optimal when we only have an nvim window that's just 2-3 lines high
-- Never show the status line
vim.opt.laststatus = 0
-- Don't show the line and column of the cursor position
vim.opt.ruler = false
-- Don't show the last command in the last line
vim.opt.showcmd = false

-- Don't show open tabs and buffers on the first line
vim.opt.showtabline = 0
