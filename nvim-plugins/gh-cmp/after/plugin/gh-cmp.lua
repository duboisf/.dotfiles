local cmp = require('cmp')
local org_users = require('gh-cmp.users.org').new()
---@diagnostic disable-next-line: param-type-mismatch
cmp.register_source('gh_org_users', org_users)
