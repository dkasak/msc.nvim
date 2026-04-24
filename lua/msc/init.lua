local M = {}
local common = require('msc.common')
local unpack = unpack or table.unpack

function M.open_msc()
    local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local current_line = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]

    local msc_number = current_line:match(common.msc_pattern)

    if msc_number then
        local url = "https://github.com/matrix-org/matrix-spec-proposals/pull/" .. msc_number

        vim.fn.system({ "xdg-open", url })
        print("Opened " .. url)
    else
        print("No MSC reference found")
    end
end

function M.setup()
    vim.cmd([[
    command! OpenMSC lua require('msc').open_msc()
    ]])
end

return M
