local cmp = require('cmp')
local org_users = require('gh-cmp.org-users').new()
cmp.register_source('gh_org_users', org_users)
