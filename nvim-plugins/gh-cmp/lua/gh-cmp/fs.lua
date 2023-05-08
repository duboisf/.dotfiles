local M = {}
local a = require "plenary.async"

--- Read a file and return its contents.
--- Uses plenary.async so must be called within an async context.
---@param path string
---@return nil|string err, string|nil data
function M.read_file(path)
  ---@type nil|string
  local err
  ---@type integer|nil
  local fd
  err, fd = a.uv.fs_open(path, "r", 438)
  if err or fd == nil then
    return "failed to open file: " .. tostring(err), nil
  end
  ---@type uv.aliases.fs_stat_table|nil
  local stat
  err, stat = a.uv.fs_stat(path)
  if err or stat == nil then
    return "failed to stat file: " .. tostring(err), nil
  end
  ---@type string|nil
  local data
  err, data = a.uv.fs_read(fd, stat.size)
  if err or data == nil then
    return "failed to read file: " .. tostring(err), nil
  end
  ---@type boolean|nil
  local success
  err, success = a.uv.fs_close(fd)
  if err or not success then
    return "failed to close file: " .. tostring(err), nil
  end
  return nil, data
end

--- Overwrite a file with the given data.
--- Uses plenary.async so must be called within an async context.
---@param path string
---@param data string
---@return nil|string err
function M.write_file(path, data)
  ---@type nil|string
  local err
  ---@type integer|nil
  local fd
  err, fd = a.uv.fs_open(path, "w+", 438)
  if err or fd == nil then
    return "failed to open file: " .. tostring(err)
  end
  ---@type integer|nil
  local bytes
  err, bytes = a.uv.fs_write(fd, data, 0)
  if err or bytes == nil then
    return "failed to write file: " .. tostring(err)
  end
end

function M.dir_exists(_) return nil, true end

function M.mkdirs(_) return nil, true end

return M
