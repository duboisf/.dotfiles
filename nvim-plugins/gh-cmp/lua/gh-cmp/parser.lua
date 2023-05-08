local parse = {}

---@class ghcmp.GitHubRemoteUrl
---@field owner string
---@field repo string

---@param line string
---@return ghcmp.GitHubRemoteUrl|nil
function parse.github_remote_line(line)
  if not (line:match("^git@github.com:") or line:match("^https://github.com/")) then
    return nil
  end
  local owner, repo = line:match("github.com.(.+)/(.+)")
  return { owner = owner, repo = repo }
end

return parse
