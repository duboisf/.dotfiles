local source = require 'gh-cmp.users.org'

describe('format_documentation', function()
  it('should format the documentation correctly (duh)', function()
    local org_name = 'AwesomeOrg'
    ---@type ghcmp.OrgMemberEdge
    local edge = {
      node = {
        location = 'Montréal',
        bio = 'I am a human',
        socialAccounts = {
          nodes = {
            {
              displayName = '@somebody',
              provider = 'TWITTER',
              url = 'https://twitter.com/somebody',
            },
          },
        },
      },
      role = 'MEMBER',
    }
    local expected = [[Member of AwesomeOrg org
Located in Montréal
 [@somebody](https://twitter.com/somebody)

I am a human]]
    local actual = source.format_documentation({ org_name = org_name, edge = edge })
    assert.are.equal(expected, actual)
  end)
end)
