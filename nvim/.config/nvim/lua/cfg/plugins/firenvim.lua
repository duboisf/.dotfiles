local group = vim.api.nvim_create_augroup("cfg#firenvim", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  pattern = "github.com_*.txt",
  desc = "Set filetype to markdown when using firenvim on github",
  command = "set filetype=markdown",
})

vim.g.firenvim_config = {
  globalSettings = {
    alt = 'all',
  },
  localSettings = {
    ['.*'] = {
      cmdline = 'neovim',
      priority = 0,
      selector = 'textarea',
      takeover = 'never',
    },
  }
}
