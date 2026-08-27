local M = {}
local devicons = require("nvim-web-devicons")

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
    if path:find("oil:", 1, true) then
        return "%#Winbar# *** OIL-EXPLORER ***"
    end

    local win_width = vim.api.nvim_win_get_width(0)
    local use_short = win_width < 80 or #path > 60 or vim.o.columns < 100

    local segments = {}
    if use_short then
        segments = get_last_segments(path, 2) -- last dir + file
    else
        segments = get_last_segments(path, 3) -- last 2 dirs + file
        -- path = path:gsub("^/", "")
        -- for part in string.gmatch(path, "[^/]+") do
        --     table.insert(segments, part)
        -- end
    end

    local separator = " %#WinbarSeparatorDim# "
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
            table.insert(rendered, string.format("%%#WinBarDir#%s %s", icon, segment))
        end
    end

    return " " .. table.concat(rendered, separator)
end

local function update_winbar(winid)
    if not vim.api.nvim_win_is_valid(winid) then
        return
    end

    local config = vim.api.nvim_win_get_config(winid)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local should_show = not config.zindex
        and vim.api.nvim_buf_get_name(bufnr) ~= ""
        and (vim.bo[bufnr].buftype == "" or vim.wo[winid].diff)

    if not should_show then
        vim.wo[winid].winbar = ""
        return
    end

    vim.api.nvim_win_call(winid, function()
        vim.wo.winbar = M.render()
    end)
end

local winbar_group = vim.api.nvim_create_augroup("winbar", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
    group = winbar_group,
    callback = function()
        update_winbar(vim.api.nvim_get_current_win())
    end,
})

vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = winbar_group,
    callback = function()
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
            update_winbar(winid)
        end
    end,
})

return M
