local utils = require 'core.utils'

describe('short_plugin_name', function()
  it('should take the fully qualified plugin name and return the short plugin name', function()
    -- given
    local full_plugin_name = 'github_owner/plugin-name.nvim'
    -- when
    local plugin_name = utils.packer.short_plugin_name(full_plugin_name)
    -- then
    assert.are.equal('plugin-name', plugin_name)
  end)
end)

describe('filepath_to_lua_module', function()
  it('should convert the full filepath to a lua module', function()
    -- given
    local filepath = 'nvim/.config/nvim/lua/core/utils.lua'
    -- when
    local module = utils.filepath_to_lua_module(filepath)
    -- then
    assert.are.equal('core.utils', module)
  end)
end)
