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

-- Curry allows, as it's name implies, to curry a function
function M.curry(f, ...)
  local n = select("#", ...)
  local args = { ... }
  return function(...)
    local n2 = select("#", ...)
    local args2 = {...}
    for i = 1, n2 do
      n = n + 1
      args[n] = args2[i]
    end
    return f(unpack(args, 1, n + n2))
  end
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

function M.filepath_to_lua_module(filepath)
  local runtimepath_striped_filepath = string.gsub(filepath, '^.*/lua/', '')
  return string.gsub(string.gsub(runtimepath_striped_filepath, '%.lua$', ''), '/', '.')
end

local function reload_module(module)
  package.loaded[module] = nil
  require(module)
  vim.notify('Reloaded lua module ' .. module)
end

local function reload_module_file(filepath)
  local module = M.filepath_to_lua_module(filepath)
  reload_module(module)
end

function M.reload_module(module)
  if vim.fn.filereadable(module) then
    reload_module_file(module)
  elseif package.loaded[module] then
    reload_module(module)
  else
    error('could not detect current file')
  end
end

M.packer = {}

function M.packer.short_plugin_name(plugin_name)
  for _, pattern in ipairs({ '.+/', '^nvim%-', '^vim%-', '%.nvim$', '%.vim$' }) do
    plugin_name = string.gsub(plugin_name, pattern, '')
  end
  return plugin_name
end

return M
