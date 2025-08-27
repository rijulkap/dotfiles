local M = {}
local devicons = require("nvim-web-devicons")
local mocha = require("catppuccin.palettes").get_palette("mocha")

vim.api.nvim_set_hl(0, "WinBarDir", { fg = mocha.lavender, bold = true })
vim.api.nvim_set_hl(0, "WinBar", { fg = mocha.blue, bg = mocha.crust }) -- crust = darkest bg
vim.api.nvim_set_hl(0, "WinBarFile", { fg = mocha.peach, bold = true })

local function get_last_segments(path, count)
    path = path:gsub("\\", "/")
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
        table.insert(parts, part)
    end
    local start_idx = math.max(#parts - count + 1, 1)
    local segments = {}
    for i = start_idx, #parts do
        table.insert(segments, parts[i])
    end
    return segments
end

---@return string
function M.render()
    local path = vim.fs.normalize(vim.fn.expand("%:p"))
    if path == "" then
        return ""
    end

    if path:find("gitsigns:") then
        return "%#Winbar# GIT DIFF"
    end

    local win_width = vim.api.nvim_win_get_width(0)
    local use_short = win_width < 80 or #path > 60 or vim.o.columns < 100

    local segments = {}
    if use_short then
        segments = get_last_segments(path, 2) -- last 2 dirs + file
    else
        path = path:gsub("^/", "")
        for part in string.gmatch(path, "[^/]+") do
            table.insert(segments, part)
        end
    end

    local separator = " %#WinbarSeparator# "
    local rendered = {}

    for i, segment in ipairs(segments) do
        local icon = "" -- default folder icon
        local hl = "DevIconDefault"

        if i == #segments then
            local fname = vim.fn.expand("%:t")
            local ico, group = devicons.get_icon(fname, nil, { default = true })
            icon = ico or ""
            hl = group or "DevIconDefault"

            -- render icon + filename with different groups
            table.insert(rendered, string.format("%%#%s#%s %%#WinBarFile#%s", hl, icon, fname))
        else
            if use_short and i == 1 then
                icon = ""
            end
            table.insert(rendered, string.format("%%#%s#%s %%#Winbar#%s", hl, icon, segment))
        end

        if segment:find("oil:") then
            icon = ""
            segment = "*** OIL-EXPLORER ***"
        end
    end

    return " " .. table.concat(rendered, separator)
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "VimResized", "WinResized" }, {
    group = vim.api.nvim_create_augroup("winbar", { clear = true }),
    callback = function()
        local winbar = require("winbar")

        for _, winid in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(winid)
            local bufnr = vim.api.nvim_win_get_buf(winid)

            if
                not config.zindex
                and vim.api.nvim_buf_get_name(bufnr) ~= ""
                and (vim.bo[bufnr].buftype == "" or vim.wo.diff)
            then
                vim.api.nvim_win_call(winid, function()
                    vim.wo.winbar = winbar.render()
                end)
            end
        end
    end,
})

return M
