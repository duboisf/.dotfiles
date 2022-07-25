local M = {}

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

return M
