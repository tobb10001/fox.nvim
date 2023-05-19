local Job = require("plenary.job")
local Path = require("plenary.path")

local cache = require("fox.cache")
local log = require("fox.log")
local u = require("fox.utils")

M = {}

local gql_path = Path:new(
  Path:new(debug.getinfo(1, "S").source:sub(2)) -- current file location
  :parents()[1]                                 -- current file directory
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

local gql_queries = (function()
  local result = {}
  local gql_paths = vim.split(vim.fn.glob(gql_path .. "**/*.gql"), "\n")
  for _, path in pairs(gql_paths) do
    local basename = file_basename(path, ".gql")
    result[basename] = u.read_file(path)
  end
  return result
end)()

local function graphql_call(query_name, variables, hostname)
  variables.query = gql_queries[query_name]
  -- Convert variables to fields.
  -- As explained in glab-api(1), fields are provided with the -F / --field flag, and
  -- each field is added to the request body as JSON.
  -- For the graphql endpoint, all fields except query and operationName are treated
  -- as variables.
  local args = { "api", "graphql" }

  for k, v in pairs(variables) do
    args[#args + 1] = "--field"
    args[#args + 1] = k .. "=" .. v
  end

  if hostname ~= nil then
    args[#args + 1] = "--hostname"
    args[#args + 1] = hostname
  end

  local job = Job:new({
    command = "glab",
    args = args,
  })
  local stdout, code = job:sync()

  if code ~= 0 then
    error(
      "Failed to perform GraphQL call. glab returned with non-zero exit code " .. code .. ": " .. job:stderr_result())
  end

  local tab = vim.json.decode(table.concat(stdout, ""))

  if tab == nil or tab.errors ~= nil then
    error("Error on GraphQL call: " .. tab.errors[1].message, vim.log.levels.ERROR)
  end

  return tab.data
end

function M.get_data(key, variables, opts)
  opts = opts or {}
  -- Create a key.
  -- The key consists of the actual key, as well as an addition, that is inferred from
  -- the variables.
  local var_key = table.concat(variables, "")
  local cache_key = key .. var_key
  -- See if we can get something from the cache.
  local cached = nil
  if not opts.force_reload then
    cached = cache.get(cache_key, { max_age = opts.max_age })
  end
  if cached then
    return cached
  else
    data = graphql_call(key, variables)
    cache.set(cache_key, data)
    return data
  end
end

return M
