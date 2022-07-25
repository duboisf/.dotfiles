local utils = require 'core.utils'

vim.api.nvim_create_user_command('ReloadModule', function(opts)
  local file_or_module = opts.args ~= '' and opts.args or vim.fn.expand('%')
  if vim.fn.filereadable(file_or_module) then
    utils.reload_module_file(file_or_module)
  elseif package.loaded[file_or_module] then
    utils.reload_module(file_or_module)
  else
    error('could not detect current file')
  end
end, {
  nargs = '?'
})
