local M = {}

-- Simplify creating autogroups
function M.autogroup(name, clear)
  local opts = { clear = clear or false }
  local group = vim.api.nvim_create_augroup(name, opts)
  return function (events, pattern, callback, desc, o)
    return M.autocmd(group, events, pattern, callback, desc, o)
  end
end

-- Simplify creating autocmds
function M.autocmd(group, events, pattern, callback, desc, opts)
  opts = opts or {}
  opts.desc = desc
  opts.group = group
  if opts.buffer == nil then
    opts.pattern = pattern
  end
  if type(callback) == 'string' then
    opts.command = callback
  elseif type(callback) == 'function' then
    opts.callback = callback
  else
    error('core.utils#autocmd: callback param must be either string or function, got: ' .. type(callback))
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

M.packer = {}

function M.packer.short_plugin_name(plugin_name)
  for _, pattern in ipairs({ '.+/', 'nvim%-', '%.nvim$' }) do
    plugin_name = string.gsub(plugin_name, pattern, '')
  end
  return plugin_name
end

return M
