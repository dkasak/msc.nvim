local msc = {}

function msc.resolve_msc()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local current_line = vim.api.nvim_buf_get_lines(0, line-1, line, false)[1]

  local pattern = "[Mm][Ss][Cc][%s_]?(%d%d%d%d%d?)"
  local msc_number = current_line:match(pattern)

  if msc_number then
    local url = "https://github.com/matrix-org/matrix-spec-proposals/pull/" .. msc_number

    vim.fn.system({"xdg-open", url})
    print("Opened " .. url)
  else
    print("No MSC reference found")
  end
end

function msc.setup()
    vim.cmd [[
    command! ResolveMSC lua require('msc').resolve_msc()
    ]]
end

return msc
