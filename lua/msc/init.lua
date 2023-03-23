local msc = {}

local msc_pattern = "[Mm][Ss][Cc][%s_]?(%d%d%d%d%d?)"

function msc.open_msc()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    local current_line = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]

    local msc_number = current_line:match(msc_pattern)

    if msc_number then
        local url = "https://github.com/matrix-org/matrix-spec-proposals/pull/" .. msc_number

        vim.fn.system({ "xdg-open", url })
        print("Opened " .. url)
    else
        print("No MSC reference found")
    end
end

function msc.setup()
    vim.cmd([[
    command! OpenMSC lua require('msc').open_msc()
    ]])

    local hover_present, hover = pcall(require, "hover.async")

    if hover_present then
        local api, fn = vim.api, vim.fn

        local async = require("hover.async")

        local function enabled()
            return fn.expand("<cWORD>"):match(msc_pattern) ~= nil
        end

        local function process(result)
            local ok, json = pcall(vim.json.decode, result)
            if not ok then
                async.scheduler()
                vim.notify("Failed to parse gh result", vim.log.levels.ERROR)
                return
            end

            local lines = {
                string.format("#%d: %s", json.number, json.title),
                "",
                string.format("URL: %s", json.url),
                string.format("Author: %s", json.author.login),
                string.format("State: %s", json.state),
                string.format("Created: %s", json.createdAt),
                string.format("Last updated: %s", json.updatedAt),
                "",
            }

            for _, l in ipairs(vim.split(json.body, "\r?\n")) do
                lines[#lines + 1] = l
            end

            return lines
        end

        local execute = async.void(function(done)
            local bufnr = api.nvim_get_current_buf()
            local cwd = fn.fnamemodify(api.nvim_buf_get_name(bufnr), ":p:h")
            local id = fn.expand("<cword>")

            local word = fn.expand("<cWORD>")

            local output

            local fields = "author,title,number,body,state,createdAt,updatedAt,url"

            local job = require("hover.async.job").job

            num = word:match(msc_pattern)
            if num then
                ---@type string[]
                output = job({
                    "gh",
                    "-R",
                    "matrix-org/matrix-spec-proposals",
                    "issue",
                    "view",
                    "--json",
                    fields,
                    num,
                    cwd = cwd,
                })
            else
                done(false)
                return
            end

            local results = process(output)
            done(results and { lines = results, filetype = "markdown" })
        end)

        require("hover").register({
            name = "MSC",
            priority = 200,
            enabled = enabled,
            execute = execute,
        })
    end
end

return msc
