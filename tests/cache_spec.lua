local cache = require("fox.cache")

describe("retrieve cache entry", function()
  it("retrieve the correct value", function()
    cache.set("key", "value")
    local result = cache.get("key")
    assert.are.equal("value", result)
  end)
end)
