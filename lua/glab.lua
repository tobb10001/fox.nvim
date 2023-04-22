local M = {}
local plenary = require("plenary")
local Job = plenary.job

M.call_glab = function (args)
    return Job:new({
      command = "glab",
      args = args,
    })
end

return M
