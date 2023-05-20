local api = require("fox.api_service")

local M = {}

function M.issue_list()
  local issues = api.get_issues()
  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(win, buf)

  local lines = {}

  for iid, issue in pairs(issues) do
    lines[#lines + 1] = "#" .. iid .. " " .. issue.title
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return M
