local api = require("fox.api_service")

local M = {}

function M.issue_list()
  local issues = api.get_issues()
  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(win, buf)

  for _, issue in ipairs(issues) do
    vim.api.nvim_buf_set_lines(buf, 1, 1, false, { "#" .. issue.iid .. " " .. issue.title })
  end
end

return M
