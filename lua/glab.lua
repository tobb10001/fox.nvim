local M = {}
local plenary = require("plenary")
local Job = plenary.job

function M.call_glab(args)
  return Job:new({
    command = "glab",
    args = args,
  })
end

return M
