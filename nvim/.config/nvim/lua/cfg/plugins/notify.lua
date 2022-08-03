require('notify').setup {
  fps = 120,
  max_width = 120,
  timeout = 3000
}

vim.notify = require('notify')
