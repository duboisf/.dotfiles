local Cache = require("gh-cmp.cache")

-- local fsMock = {
--   read_file = function(_)
--     return nil, "data"
--   end,
--   -- write_file = function(_, _)
--   --   return nil
--   -- end
-- }
--
describe("cache", function()
  it("can save a cache item", function()
    -- Given
    local cache = Cache.new("not important", {})

    -- When
    local cache_item = { isComplete = false, items = {} }
    cache:set("some_owner", cache_item)
    local actual_cache_item = cache:get("some_owner")

    -- Then
    if actual_cache_item == nil then
      error("Cache item is nil")
    end
    assert.are.equal(cache_item, actual_cache_item.items)
  end)
end)

