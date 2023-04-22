vim.api.nvim_command('set runtimepath+=./lib/plenary.nvim')

local plenary = require("plenary")
local Job = plenary.job

local stdout, code = Job:new({
  command = "glab",
  enable_handlers = true,
  enable_recording = true,
  on_stdout = function (chunk)
    if chunk ~= nil then
      print(chunk)
    end
  end,
  on_stderr = function (chunk)
    if chunk ~= nil then
      print(chunk)
    end
  end,
  on_exit = function(j, return_val)
    print(return_val)
    print(vim.inspect(j:result()))
    print(j:result()[1])
  end,
}):sync()

vim.inspect(stdout, "\n")
