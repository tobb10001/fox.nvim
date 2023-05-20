local client = require("fox.api_client")
local utils = require("fox.utils")

local M = {}

function M.get_issues()
  local project = client.get_data("project", { fullPath = utils.origin_project_path() }).project
  -- convert to mapping iid -> issue node
  local map = {}
  for _, node in ipairs(project.issues.nodes) do
    map[node.iid] = node
  end
  return map
end

return M
