require("gh-cmp.utils").when_inside_github_repo(function(remote)
  local cmp = require("cmp")
  local org_users = require("gh-cmp.org_users").new(remote.user)
  vim.defer_fn(function()
    ---@diagnostic disable-next-line: param-type-mismatch
    cmp.register_source("gh_org_users", org_users)
  end, 10)
end)
