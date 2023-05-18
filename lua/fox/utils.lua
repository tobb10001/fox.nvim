local Job = require("plenary.job")

local M = {}

function M.read_file(file)
  local f = io.open(file, "rb")
  if f == nil then
    error("File not found.")
  end
  local result = f:read("*a")
  f:close()
  return result
end

function M.extract_project_path(url)
  local left_char
  if url:find("^https://") ~= nil then
    url = url:sub(#"https://" + 1)
    left_char = "/"
  elseif url:find("^http://") ~= nil then
    url = url:sub(#"http://" + 1)
    left_char = "/"
  else
    left_char = ":"
  end
  local pos = url:find(left_char)
  local path = url:sub(pos + 1)
  if url:find(".git$") then
    path = path:sub(1, -5)
  end
  return path
end

function M.origin_project_path()
  local job = Job:new({
    command = "git",
    args = { "remote", "get-url", "origin" }
  })
  local stdout, code = job:sync()

  if code ~= 0 then
    local msg = "Failed to read the project path. git returned with non-zero exit code " ..
        code .. ": " .. job:stderr_result()
    vim.notify(msg, vim.log.levels.ERROR)
    error(msg)
  end
  return M.extract_project_path(stdout[1])
end

return M
