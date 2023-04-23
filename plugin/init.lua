local M = {}

local glab = require("glab")

vim.api.nvim_create_user_command('Glab', function (opts)
    local args = opts.fargs

    local glab_job = glab.call_glab(args)

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buffer, 'bufhidden', 'wipe')

    local cols, rows = vim.api.nvim_get_option('columns'), vim.api.nvim_get_option("lines")

    vim.api.nvim_open_win(buffer, true, {
	relative = "editor",
	col = math.floor(cols * 0.1 + 0.5),
	row = math.floor(rows * 0.1 + 0.5),
	width = math.floor(cols * 0.8 + 0.5),
	height = math.floor(rows * 0.8 + 0.5),
	style = "minimal",
	border = "solid",
	title = "glab " .. table.concat(args, " "),
	title_pos = "center",
    })
    local term_chan = vim.api.nvim_open_term(buffer, {})

    local stdout, _ = glab_job:sync()
    stdout = table.concat(stdout, "\r\n")

    vim.api.nvim_chan_send(term_chan, stdout)
    end,
    {
	nargs = "*",
	desc = "Call the `glab` executable. Equivalent to calling `:!glab`, but renders the output in a floating window.",
    }
)

return M
