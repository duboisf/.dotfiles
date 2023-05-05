local Job = require("plenary.job")

local M = {}

---@class ghcmp.GitHubRemoteUrl
---@field user string
---@field repo string

---@param line string
---@return ghcmp.GitHubRemoteUrl?
local function parse_github_remote_line(line)
  if not line then
    return nil
  end
  if not (line:match("^git@github.com:") or line:match("^https://github.com/")) then
    return nil
  end
  local username, repo = line:match("github.com.(.+)/(.+)")
  return { user = username, repo = repo }
end

---@param callback fun(remote: string)
---@return nil
local function get_git_origin_remote(callback)
  Job:new({
    "git",
    "remote",
    "get-url",
    "--push",
    "origin",
    on_exit = function(job, exit_code)
      if exit_code == 0 then
        callback(job:result()[1])
      end
    end,
  }):start()
end

---@param callback fun(remote: ghcmp.GitHubRemoteUrl)
---@return nil
function M.when_inside_github_repo(callback)
  get_git_origin_remote(function(remote)
    local parsed = parse_github_remote_line(remote)
    if parsed then
      callback(parsed)
    end
  end)
end

---@param path string
---@return string?
function M.read_file(path)
  local fd, err = io.open(path)
  if err then
    return nil
  end
  if not fd then
    return nil
  end
  local data
  data, err = fd:read("*a")
  fd:close()
  if err then
    return nil
  end
  return data
end

---@param path string
---@param data string
function M.write_file(path, data)
  local fd, err = io.open(path, "w")
  if err then
    return nil
  end
  if not fd then
    return nil
  end
  _, err = fd:write(data)
  fd:close()
end

return M
