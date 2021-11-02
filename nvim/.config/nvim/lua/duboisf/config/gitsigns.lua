local loaded, gitsigns = pcall(require, 'gitsigns')
if loaded then
  gitsigns.setup {
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 3000,
    },
    preview_config = {
      border = 'rounded',
      row = 1,
    },
    word_diff = true,
  }
end
