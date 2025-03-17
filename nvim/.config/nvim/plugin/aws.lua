local function GetValue(key)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    local value = line:match("^" .. key .. ":%s*(.+)")
    if value then
      return value
    end
  end
  return nil
end

function OpenECRRepository()
  local accountId = GetValue("account")
  local sessionId = GetValue("session")
  if not accountId then
    print("accountId not found")
    return
  end
  if not sessionId then
    print("sessionId not found")
    return
  end
  local repository = vim.api.nvim_get_current_line()
  local url = table.concat({
    "https://",
    accountId,
    "-",
    sessionId,
    ".us-east-1.console.aws.amazon.com/ecr/repositories/private/",
    accountId,
    "/",
    repository
  })
  os.execute("xdg-open " .. url)
end

vim.api.nvim_set_keymap('n', '<leader>oe', ':lua OpenECRRepository()<CR>', { noremap = true, silent = true })
