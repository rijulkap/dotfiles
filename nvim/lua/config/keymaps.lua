vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "H", "^", { noremap = true })
vim.keymap.set("n", "L", "$", { noremap = true })

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set("n", "q:", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1 })
end, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1 })
end, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "[e", function()
    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]e", function()
    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })

vim.keymap.set("n", "<leader>xr", "*``cgn", { desc = "Replace word" })

vim.keymap.set("n", "<C-o>", "<C-o>zz")

-- vim.keymap.set('n', '<C-d>', '<C-d>zz')
-- vim.keymap.set('n', '<C-u>', '<C-u>zz')

vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })

-- Quickfix
vim.keymap.set("n", "<leader>xq", function()
    local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
    if not success and err then
        vim.notify(err, vim.log.levels.ERROR)
    end
end, { desc = "Quickfix List" })

-- Location
vim.keymap.set("n", "<leader>xl", function()
    local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
    if not success and err then
        vim.notify(err, vim.log.levels.ERROR)
    end
end, { desc = "Location List" })

-- Add undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- Change window focus
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<A-1>", "mA")
vim.keymap.set("n", "<leader>m1", "`A")
vim.keymap.set("n", "<A-2>", "mB")
vim.keymap.set("n", "<leader>m2", "`B")
vim.keymap.set("n", "<A-3>", "mC")
vim.keymap.set("n", "<leader>m3", "`C")
vim.keymap.set("n", "<A-4>", "mD")
vim.keymap.set("n", "<leader>m4", "`D")
vim.keymap.set("n", "<A-5>", "mE")
vim.keymap.set("n", "<leader>m5", "`E")

-- local keypress = function()
--     local ok = true
--     for _, key in ipairs { 'h', 'j', 'k', 'l' } do
--         local count = 0
--         local timer = assert(vim.uv.new_timer())
--         local map = key
--         vim.keymap.set('n', key, function()
--             if vim.v.count > 0 then
--                 count = 0
--             end
--             if count >= 10 and vim.bo.buftype ~= 'nofile' then
--                 ok = pcall(vim.notify, 'Hold it Cowboy!', vim.log.levels.WARN, {
--                     icon = '🤠',
--                     id = 'cowboy',
--                     keep = function()
--                         return count >= 10
--                     end,
--                 })
--                 if not ok then
--                     return map
--                 end
--             else
--                 count = count + 1
--                 timer:start(2000, 0, function()
--                     count = 0
--                 end)
--                 return map
--             end
--         end, { expr = true, silent = true })
--     end
-- end

-- keypress()
