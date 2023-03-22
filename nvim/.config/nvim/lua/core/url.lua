local M = {}

local function hex_to_char(x)
  return string.char(tonumber(x, 16))
end

function M.decode(url)
  if url == nil then
    return nil
  end
  return url:gsub('%%(%x%x)', hex_to_char)
end

return M
