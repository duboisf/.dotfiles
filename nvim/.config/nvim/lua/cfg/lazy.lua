local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local clone_output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { clone_output,                   "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

---@type LazyConfig
local opts = {
  spec = {
    { import = "plugins" },
  },
  dev = {
    path = "~/git",
  },
  install = {
    -- try to load one of these colorschemes when starting an installation during startup
    colorscheme = { "habamax" },
  },
  checker = {
    enabled = false,
  },
}

require("lazy").setup(opts)
