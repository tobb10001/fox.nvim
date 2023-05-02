local Event = require("fox.event")

describe("events", function()
  it("can be created", function()
    Event.new()
  end)

  it("has a subscibe method", function() 
    local event = Event.new()
    assert.are.equal("function", type(event.subscribe))
  end)

  it("saves subscribed functions", function()
    local function fun() end
    local event = Event.new()
    event:subscribe(fun)

    assert.are.equal(fun, event._subscribers[1])
  end)

  it("subscribed functions are called", function ()
    local event = Event.new()
    local called = false
    local function callee() called = true end
    event:subscribe(callee)
    event:emit()
    assert.is_true(called)
  end)

  it("subscribed functions are called with params", function ()
    local event = Event.new()
    local called_with = nil
    local function callee(param) called_with = param end
    event:subscribe(callee)

    event:emit("foo")
    assert.are.equal("foo", called_with)
  end)
end)
