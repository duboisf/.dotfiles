local M = {}
local Job = require("plenary.job")
local parse = require("gh-cmp.parser")
local git = require("gh-cmp.git")

local graphql_query = [[
  query ($org: String!, $endCursor: String) {
    organization(login: $org) {
      name
      membersWithRole(first: 100, after: $endCursor) {
        edges {
          node {
            login
            name
            bio
            location
            company
            socialAccounts(first:20) {
              nodes {
                displayName
                provider
                url
              }
            }
            status {
              emojiHTML
              indicatesLimitedAvailability
              message
            }
          }
          role
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  }
]]

---@class ghcmp.OrgMembersQueryResult
---@field data ghcmp.OrgMembersQueryResultData

---@class ghcmp.OrgMembersQueryResultData
---@field organization ghcmp.Organization

---@class ghcmp.Organization
---@field name string The name of the organization
---@field membersWithRole ghcmp.OrgMemberConnection

---@class ghcmp.OrgMemberConnection
---@field edges ghcmp.OrgMemberEdge[]
---@field pageInfo ghcmp.PageInfo

---@class ghcmp.PageInfo
---@field hasNextPage boolean
---@field endCursor? string

---@alias ghcmp.Role
---| ""ADMIN""
---| ""MEMBER""

---@class ghcmp.OrgMemberEdge
---@field node ghcmp.User
---@field role ghcmp.Role

---@class ghcmp.User
---@field login string
---@field name string?
---@field bio string?
---@field location string?
---@field company string?
---@field socialAccounts ghcmp.SocialAccounts
---@field status ghcmp.Status

---@class ghcmp.Status
---@field emojiHTML string?
---@field indicatesLimitedAvailability boolean
---@field message string?

---@class ghcmp.SocialAccounts
---@field nodes ghcmp.SocialAccount[]

---@class ghcmp.SocialAccount
---@field displayName string
---@field provider string
---@field url string

---@param github_owner string
---@param callback fun(ok: boolean, result: ghcmp.OrgMembersQueryResult?)
function M.org_users(github_owner, callback)
  local job = Job:new({
    "gh",
    "api",
    "--paginate",
    "graphql",
    "-F",
    "org=" .. github_owner,
    "-f",
    "query=" .. graphql_query,
    on_stderr = function(err, data)
      vim.schedule_wrap(function()
        vim.api.nvim_err_writeln("gh-cmp: could not get org users for " .. github_owner .. ": " .. data)
      end)()
    end,
    on_exit = function(job, code)
      if code ~= 0 then
        callback(false, nil)
      else
        local ok, parsed = pcall(
          vim.json.decode,
          job:result()[1],
          { luanil = { object = true, array = true } }
        )
        callback(ok, parsed)
      end
    end,
  })
  job:start()
end

---Do something when cwd is inside a GitHub repo.
---
---The callback is only called when the current working
---directory is inside a git repository that has a remote
---named `origin` that is a GitHub repository.
---@param callback fun(remote: ghcmp.GitHubRemoteUrl)
---@return nil
function M.when_in_github_repo(callback)
  git.remote("origin", function(remote)
    local parsed = parse.github_remote_line(remote)
    if parsed then
      callback(parsed)
    end
  end)
end

return M
