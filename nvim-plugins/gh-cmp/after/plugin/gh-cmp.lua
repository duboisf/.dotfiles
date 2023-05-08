local Cache = require "gh-cmp.cache"
local Source = require "gh-cmp.source"
local a = require "plenary.async"
local fs = require("gh-cmp.fs")
local github = require "gh-cmp.github"

---@type string
local cache_file = vim.fn.stdpath("cache") .. "/gh-cmp/org-users.json"

github.when_in_github_repo(function(remote)
  local cache = Cache.new(cache_file, 60 * 60, fs)
  a.void(function()
    cache:load()
  end)()
  local gh_org_users = Source.new(cache, remote.owner)
  vim.schedule_wrap(function()
    ---@diagnostic disable-next-line: param-type-mismatch
    require("cmp").register_source("gh_org_users", gh_org_users)
  end)()
end)
