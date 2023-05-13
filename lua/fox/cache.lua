--[[ Caching

Just a simple key value cache, that tracks the age of cache entries. ]]

local M

local cache = {}

function M.set(key, value)
  cache[key] = { time = os.time(), data = value }
end

function M.get(key, max_age)
  if not cache[key] then
    return nil
  end
  if max_age and os.time() - cache[key].time > max_age then
    return nil
  end
  return cache.data
end

return M
