local Event = require("fox.event")
local Job = require("plenary.job")
local Path = require("plenary.path")

M = {}

M.events = {
  project_info = Event(),
}
M.data = {}

local gql_path = Path:new(
  Path:new(debug.getinfo(1, "S").source:sub(2)) -- current file location
    :parents()[1] -- current file directory
):joinpath("gql")

local gql_project_info = (function ()
  local f = io.open(gql_loc, "rb")
  if f == nil then
    error("File not found.")
  end
  local result = f:read("*a")
  f:close()
  return result
end)()

local function graphql_call(gql, variables, hostname)
  variables.query = gql
  -- Convert variables to fields.
  -- As explained in glab-api(1), fields are provided with the -F / --field flag, and
  -- each field is added to the request body as JSON.
  -- For the graphql endpoint, all fields except query and operationName are treated
  -- as variables.
  local args = { "api", "graphql" }
  for k, v in pairs(variables) do
    args[#args+1] = "--field"
    args[#args+1] = k .. "=" .. v
  end

  if hostname ~= nil then
    args[#args+1] = "--hostname"
    args[#args+1] = hostname
  end

  local job = Job:new({
    command = "glab",
    args = args,
    on_exit = function(j, return_val)
      if return_val ~= 0 then
        vim.api.nvim_err_write("glab exited with non-zero exit code " .. return_val .. "\n")
        vim.api.nvim_err_write(table.concat(j:stderr_result(), "\n"))
        return
      end
      M.data.project_info = vim.json.decode(j:result())
      M.events.project_info.emit()
    end,
  })
  job:sync()

  local stdout = table.concat(job:result(), " ")
  local stderr = table.concat(job:stderr_result(), " ")
  vim.api.nvim_out_write("stdout: " .. stdout .. "\n")
  vim.api.nvim_err_write("stderr: " .. stderr .. "\n")
end

return M
