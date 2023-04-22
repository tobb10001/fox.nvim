local M = {}

local glab = require("glab")

vim.api.nvim_create_user_command('Glab', function (opts)
    local args = opts.fargs
    local stdout, _ = glab.call_glab(args):sync()
    vim.api.nvim_out_write(table.concat(stdout, "\n") .. "\n")
end, {
    nargs = "*",
    desc = "Call the `glab` executable. Equivalent to calling `:!glab`.",
})

return M
