local M = {}

-- simplify  creating autogroups
function M.autogroup(name, clear)
  local opts = { clear = clear or false }
  return vim.api.nvim_create_augroup(name, opts)
end

-- simplicy creating autocmds
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

-- Check if nvim was started by firenvim. If so, we want to disable
-- some plugins and tweak some settings, reason being that sometimes
-- the size of the nvim window is _realy_ small (2-3 lines!)
function M.notStartedByFirenvim()
  return vim.g.started_by_firenvim == nil
end

return M
