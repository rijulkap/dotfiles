local function redraw_marks()
    -- Snacks clears its status-column cache every 50 ms, but does not redraw
    -- afterward. Redraw once the cached mark state has expired.
    vim.defer_fn(function()
        -- An uppercase mark may have moved from another visible buffer.
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            vim.api.nvim__redraw({ win = win, range = { 0, -1 } })
        end
        vim.api.nvim__redraw({ flush = true })
    end, 60)
end

---@param mark string
local function toggle_mark(mark)
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1], cursor[2]
    local is_global = mark:match("^[A-Z]$") ~= nil
    local old_pos = is_global and vim.api.nvim_get_mark(mark, {}) or vim.api.nvim_buf_get_mark(bufnr, mark)
    local is_same_line = old_pos[1] == row and (not is_global or old_pos[3] == bufnr)

    if is_same_line then
        if is_global then
            vim.api.nvim_del_mark(mark)
        else
            vim.api.nvim_buf_del_mark(bufnr, mark)
        end
    else
        -- nvim_buf_set_mark handles both local and global mark names.
        vim.api.nvim_buf_set_mark(bufnr, mark, row, col, {})
    end

    redraw_marks()
end

for mark in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):gmatch(".") do
    vim.keymap.set("n", "m" .. mark, function()
        toggle_mark(mark)
    end, { desc = "Toggle mark " .. mark })
end
