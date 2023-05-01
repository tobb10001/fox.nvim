local Path = require("plenary.path")

M = {}

local gql_loc = Path:new(
  Path:new(debug.getinfo(1, "S").source:sub(2)) -- current file location
    :parents()[1] -- current file directory
):joinpath("call.gql").filename

-- TODO: Think about making this async.
local gql = (function ()
  local f = io.open(gql_loc, "rb")
  if f == nil then
    error("File not found.")
  end
  local result = f:read("*a")
  f:close()
  return result
end)()

return M
