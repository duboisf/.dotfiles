local M = {}

function M.load()
  local theme = require 'core.colorscheme.theme'
  local lush = require 'lush'
  lush(theme)
end

return M
