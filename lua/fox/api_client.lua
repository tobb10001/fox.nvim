local Job = require("plenary.job")
local Path = require("plenary.path")

M = {}

M.data = {}

local gql_path = Path:new(
  Path:new(debug.getinfo(1, "S").source:sub(2)) -- current file location
    :parents()[1] -- current file directory
):joinpath("gql")

local function file_basename(path, ext)
  local basename = path
  local pos = -1
  repeat
    basename = basename:sub(pos + 1)
    pos = basename:find("/")
  until pos == nil
  if vim.endswith(basename, ext) then
    basename = basename:gsub(ext .. "$", "")
  end
  return basename
end

local function read_file(file)
  local f = io.open(file, "rb")
  if f == nil then
    error("File not found.")
  end
  local result = f:read("*a")
  f:close()
  return result
end

local gql_queries = (function()
  local result = {}
  local gql_paths = vim.split(vim.fn.glob(gql_path .. "**/*.gql"), "\n")
  for _, path in pairs(gql_paths) do
    local basename = file_basename(path, ".gql")
    result[basename] = read_file(path)
  end
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
  })
  local stdout, code = job:sync()

  if code ~= 0 then
    vim.notify(
      "glab returned with non-zero exit code " .. code .. ": " .. job:stderr_result(),
      vim.log.levels.ERROR)
    return
  end

  return vim.json.decode(table.concat(stdout, ""))
end

return M
