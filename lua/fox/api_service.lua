local client = require("fox.api_client")
local utils = require("fox.utils")

local M = {}

function M.get_issues()
  local project = client.get_data("project", { fullPath = utils.origin_project_path() }).project
  return project.issues.nodes
end

return M
