require('gitsigns').setup {
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 30,
  },
  preview_config = {
    border = 'rounded',
    row = 1,
  },
  word_diff = true,
}
