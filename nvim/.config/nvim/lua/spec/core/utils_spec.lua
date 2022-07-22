describe('short_plugin_name', function ()
  it('should take the fully qualified plugin name and return the short plugin name', function ()
    local utils = require 'core.utils'
    -- given
    local full_plugin_name = 'github_owner/plugin-name.nvim'
    -- when
    local plugin_name = utils.packer.short_plugin_name(full_plugin_name)
    -- then
    assert.are.equal(plugin_name, 'plugin-name')
  end)
end)
