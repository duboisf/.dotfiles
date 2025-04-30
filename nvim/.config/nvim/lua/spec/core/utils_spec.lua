---@module 'plenary.busted'

-- Use the command 'PlenaryBustedDirectory %' to run tests in this file
local utils = require('core.utils')

describe('curry', function()
  it('should curry functions with 2 parameters', function()
    -- given
    local function add(a, b)
      return a + b
    end

    -- when
    local add5 = utils.curry(add, 5)
    local result = add5(2)
    -- then
    assert.are.equal(7, result)
  end)
  it('should curry functions with 3 parameters', function()
    -- given
    local function reverse(a, b, c)
      return { c, b, a }
    end

    -- when
    local reverseA = utils.curry(reverse, 'a')
    local reverseAB = utils.curry(reverseA, 'b')
    local result = reverseAB('c')
    -- then
    assert.are.same({ 'c', 'b', 'a' }, result)
  end)

  it('should curry multiple parameters in a single call', function()
    -- given
    local function reverse(a, b, c)
      return { c, b, a }
    end

    -- when
    local reverseAB = utils.curry(reverse, 'a', 'b')
    local result = reverseAB('c')
    -- then
    assert.are.same({ 'c', 'b', 'a' }, result)
  end)

  it('should allow currying an already curried function', function()
    -- given
    local function reverse(a, b, c, d, e)
      return { e, d, c, b, a }
    end

    -- when
    local reverseAB = utils.curry(reverse, 'a', 'b')
    local reverseABCD = utils.curry(reverseAB, 'c', 'd')
    local result = reverseABCD('e')
    -- then
    assert.are.same({ 'e', 'd', 'c', 'b', 'a' }, result)
  end)

  it('should handle nil parameters', function()
    -- given
    local function reverse(a, b, c)
      return { c, b, a }
    end

    -- when
    local reverseAB = utils.curry(reverse, 'a', nil)
    local result = reverseAB('c')
    -- then
    assert.are.same({ 'c', nil, 'a' }, result)
  end)

  it('should handle nil parameters in an already currying function', function()
    -- given
    local function reverse(a, b, c, d, e)
      return { e, d, c, b, a }
    end

    -- when
    local reverseAB = utils.curry(reverse, 'a', nil)
    local reverseABCNilD = utils.curry(reverseAB, 'c', nil)
    local result = reverseABCNilD('e')
    -- then
    assert.are.same({ 'e', nil, 'c', nil, 'a' }, result)
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
