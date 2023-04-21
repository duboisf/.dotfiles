local M = {}

-- Simplify creating autogroups, returns autocmd func with augroup already bound + augroup id
function M.autogroup(name, clear)
  local opts = { clear = clear or false }
  local group = vim.api.nvim_create_augroup(name, opts)
  return function(events, pattern, callback, desc, o)
    return M.autocmd(group, events, pattern, callback, desc, o)
  end, group
end

-- Returns true if the quickfix window is currently open.
--- @return boolean
function M.is_quickfix_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
    if buftype == 'quickfix' then
      return true
    end
  end
  return false
end

-- Simplify creating autocmds. Calls vim.api.nvim_create_autocmd().
--- @param group number The id of the autocommand group.
--- @param events string|table<string> The event name(s) the autocommand should trigger on.
--- @param pattern string|table<string> The pattern to match against.
--- @param callback function|string Lua function or Vimscript function name to call when the event(s) is triggered
--- @param desc string The description of the autocommand.
--- @param opts table<string, any> Extra options to pass to the vim.api.nvim_create_autocmd function.
--- @return number
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
    local args2 = { ... }
    for i = 1, n2 do
      n = n + 1
      args[n] = args2[i]
    end
    return f(unpack(args, 1, n + n2))
  end
end

--- Check if neovim was started by firenvim
--- @return boolean
function M.startedByFirenvim()
  return vim.g.started_by_firenvim ~= nil
end

--- Check if nvim was not started by firenvim. This function is useful in the
--- packer cond key, like:
--- cond = notStartedByFirenvim
--- @return boolean
function M.notStartedByFirenvim()
  return not M.startedByFirenvim()
end

--- Replaces the home part of a path with a tilde.
--- @param path string The path to transform
--- @return string
function M.collapse_home_path_to_tilde(path)
  local home = vim.fn.getenv("HOME")
  local transformed_path = string.gsub(path, home, '~')
  return transformed_path
end

--- Returns the short form of the current working directory.
--- If the cwd is under $HOME, then the cwd will contain ~
--- instead of the full path to the home directory.
--- @return string
function M.get_short_cwd()
  local cwd = vim.fn.getcwd()
  return M.collapse_home_path_to_tilde(cwd)
end

--- Takes a filepath and returns the lua module form.
--- It replaces the slashes in the path to dots.
--- @param filepath string The path to convert to a lua module name
--- @return string
function M.filepath_to_lua_module(filepath)
  local runtimepath_striped_filepath = string.gsub(filepath, '^.*/lua/', '')
  local module = string.gsub(string.gsub(runtimepath_striped_filepath, '%.lua$', ''), '/', '.')
  return module
end

local function reload_module(module)
  package.loaded[module] = nil
  require(module)
  vim.notify('Reloaded lua module ' .. module)
end

-- Reloads a lua module given as a file path.
--- @param filepath string The path to the lua module
--- @return nil
local function reload_module_file(filepath)
  local module = M.filepath_to_lua_module(filepath)
  reload_module(module)
end

-- Reloads a lua module.
--- @param module string Either a file path to a lua module or the lua module name.
--- @return nil
function M.reload_module(module)
  if vim.fn.filereadable(module) then
    reload_module_file(module)
  elseif package.loaded[module] then
    reload_module(module)
  else
    error('could not detect current file')
  end
end

-- Returns the first character of a string
--- @param s string The string to get the first character of.
--- @return string
function M.head(s)
  return string.sub(s, 1, 1)
end

--- Check if the current working directory is inside the dotfiles directory
--- @return boolean
function M.cwd_in_dotfiles()
  return vim.fn.getcwd():match('%.dotfiles')
end

--- Inspect highlight group / Treesitter node under cursor
--- @return nil
function M.inspect_highlight()
  -- if inside a noice popup, show the highlight group under the cursor
  if vim.o.ft == 'noice' then
    local hilight_name = vim.fn.expand('<cWORD>')
    pcall(vim.cmd.highlight, hilight_name)
  else
    -- Inspect the TreeSitter node under the cursor.
    -- Because of a custom noice route, it will open in a nui popup.
    vim.cmd.Inspect()
  end
end

function M.tail(s)
  return string.sub(s, 2)
end

M.packer = {}

function M.packer.short_plugin_name(plugin_name)
  for _, pattern in ipairs({ '.+/', '^nvim%-', '^vim%-', '%.nvim$', '%.vim$', '%.lua$' }) do
    plugin_name = string.lower(string.gsub(plugin_name, pattern, ''))
  end
  return plugin_name
end

--- Check if we have networking
--- @return boolean
function M.has_network()
  return vim.g.no_network ~= true
end

return M
