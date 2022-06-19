local M = {}

function M.autogroup(name, clear)
  local opts = { clear = clear or false }
  return vim.api.nvim_create_augroup(name, opts)
end

function M.autocmd(group, events, pattern, callback, opts)
  opts = opts or {}
  if type(events) == 'string' then
    events = { events }
  end
  opts.group = group
  opts.pattern = pattern
  if type(callback) == 'string' then
    opts.command = callback
	else
    opts.callback = callback
  end
  return vim.api.nvim_create_autocmd(events, opts)
end

return M
