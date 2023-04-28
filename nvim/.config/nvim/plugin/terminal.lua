local utils = require 'core.utils'

local autocmd = utils.autogroup('duboisf.terminal', true)

autocmd('TermOpen', '*', function()
  -- disable mini.indentscope, it screws up the terminal display
  vim.b.miniindentscope_disable = true
  -- enter terminal (insert) mode as soon as the terminal buffer opens
  vim.cmd.startinsert()
end, 'Terminal buffer custom configuration', nil)
