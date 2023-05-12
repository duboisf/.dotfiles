-- Calls :InspectTree but keeps the cursor in place
local function inspectTree()
  vim.fn.setpos("'z", vim.fn.getpos('.'))
  local orig_slipright = vim.o.splitright
  vim.o.splitright = false
  vim.cmd.InspectTree()
  vim.o.splitright = orig_slipright
  vim.cmd.wincmd('w')
  vim.fn.setpos('.', vim.fn.getpos("'z"))
end

vim.keymap.set('n', '<A-t>', inspectTree, { silent = true, desc = 'Calls :InspectTree but keeps cursor in place' })
