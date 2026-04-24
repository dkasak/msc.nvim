local common = require('msc.common')
local hover_present = pcall(require, "hover")

local enabled
local execute

if hover_present then
    local api, fn = vim.api, vim.fn

    enabled = function()
        return fn.expand("<cWORD>"):match(common.msc_pattern) ~= nil
    end

    local function process(result)
        local ok, json = pcall(vim.json.decode, result)

        if not ok or not json then
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

    execute = function(_, done)
        local bufnr = api.nvim_get_current_buf()
        local cwd = fn.fnamemodify(api.nvim_buf_get_name(bufnr), ":p:h")

        local msc_id = fn.expand("<cWORD>")
        local num = msc_id:match(common.msc_pattern)

        local fields = "author,title,number,body,state,createdAt,updatedAt,url"

        if num then
            vim.system({
                    "gh",
                    "-R",
                    "matrix-org/matrix-spec-proposals",
                    "issue",
                    "view",
                    "--json",
                    fields,
                    num,
                }, { cwd = cwd },
                vim.schedule_wrap(function(output)
                    if output.code ~= 0 then
                        vim.notify("gh failed: " .. (output.stderr or ""), vim.log.levels.ERROR)
                        done(false)
                        return
                    end
                    local results = process(output.stdout)
                    done(results and { lines = results, filetype = "markdown" } or false)
                end)
            )
        else
            done(false)
            return
        end
    end
end

return {
    name = "MSC",
    priority = 200,
    enabled = enabled,
    execute = execute,
}
