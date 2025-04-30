local M = {}

--- Determine if the package path possibly corresponds to a github repo
---@param pkg_path string The package path to check
---@return string? url The URL of the GitHub repository or nil if doesn't correspond
local function pkg_to_github_repo_url(pkg_path)
  if not string.find(pkg_path, "/pkg/mod/.*%.go") then
    return nil
  end
  pkg_path = string.gsub(pkg_path, "^(.*)/pkg/mod/", "")
  local parts = vim.fn.split(pkg_path, "@")
  if #parts ~= 2 then
    return nil
  end
  local repo, versioned_path = unpack(parts)
  local path_parts = vim.fn.split(versioned_path, "/")
  if #path_parts < 2 then
    return nil
  end
  local version = table.remove(path_parts, 1)
  local path = table.concat(path_parts, "/")
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  return string.format("https://%s/blob/%s/%s#L%d", repo, version, path, line_number)
end

function M.open_github_repo_url(pkg_path)
  local github_url = pkg_to_github_repo_url(pkg_path)
  if not github_url then
    vim.notify("The package path does not correspond to a GitHub repository.")
    return nil
  end
  vim.ui.open(github_url)
end

return M
