Event = {}

local _Event__index = {}

function Event.new(o)
  o = o or {}
  setmetatable(o, {__index = _Event__index})
  return o
end

function _Event__index:subscribe(fun)
  self._subscribers = self._subscribers or {}
  table.insert(self._subscribers, fun)
end

function _Event__index:emit(...)
  for _, fun in ipairs(self._subscribers) do
    fun(...)
  end
end

return Event
