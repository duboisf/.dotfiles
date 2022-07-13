local M = {}

-- Simplify creating autogroups
function M.autogroup(name, clear)
  local opts = { clear = clear or false }
  return vim.api.nvim_create_augroup(name, opts)
end

-- Simplicy creating autocmds
function M.autocmd(group, events, pattern, callback, opts)
  opts = opts or {}
  opts.group = group
  if opts.buffer == nil then
    opts.pattern = pattern
  end
  if type(callback) == 'string' then
    opts.command = callback
	else
    opts.callback = callback
  end
  return vim.api.nvim_create_autocmd(events, opts)
end

-- Check if neovim was started by firenvim
function M.startedByFirenvim()
  return vim.g.started_by_firenvim == nil
end

-- Check if nvim was not started by firenvim. This function is useful in the
-- packer cond key, like:
-- cond = notStartedByFirenvim
function M.notStartedByFirenvim()
  return not M.startedByFirenvim()
end

function M.collapse_home_path_to_tilde(path)
  local home = vim.fn.getenv("HOME")
  return string.gsub(path, home, '~')
end

function M.get_short_cwd()
  local cwd = vim.fn.getcwd()
  return M.collapse_home_path_to_tilde(cwd)
end

function M.reload_module(module)
  package.loaded[module] = nil
  require(module)
  vim.notify('Reloaded lua module ' .. module)
end

return M
