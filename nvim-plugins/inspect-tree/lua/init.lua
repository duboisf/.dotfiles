local M = {}

-- Calls :InspectTree but keeps the cursor in place
function M.inspectTree()
  vim.fn.setpos("'z", vim.fn.getpos('.'))
  local orig_slipright = vim.o.splitright
  vim.o.splitright = false
  vim.cmd.InspectTree()
  vim.o.splitright = orig_slipright
  vim.cmd.wincmd('w')
  vim.fn.setpos('.', vim.fn.getpos("'z"))
end

function M.setup()
  vim.keymap.set('n', '<A-t>', M.inspectTree, { silent = true, desc = 'Calls :InspectTree but keeps cursor in place' })
end

return M
