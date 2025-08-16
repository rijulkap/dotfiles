vim.pack.add({ { src = "https://github.com/akinsho/bufferline.nvim" } }, { confirm = false })

vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Toggle Pin" })
vim.keymap.set("n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete Non-Pinned Buffers" })
vim.keymap.set("n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "Delete Buffers to the Right" })
vim.keymap.set("n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Delete Buffers to the Left" })
vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "[B", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer prev" })
vim.keymap.set("n", "]B", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer next" })

require("bufferline").setup({
    options = {
        tab_size = 20,
        close_command = function(n)
            Snacks.bufdelete(n)
        end,
        right_mouse_command = function(n)
            Snacks.bufdelete(n)
        end,
        separator_style = "thick",
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        indicator = { icon = "  " },
        diagnostics_indicator = function(_, _, diag)
            local ret = (diag.error and " " .. diag.error .. " " or "")
                .. (diag.warning and " " .. diag.warning or "")
            return vim.trim(ret)
        end,
        offsets = {
            {
                filetype = "snacks_layout_box",
            },
        },
    },
    highlights = require("catppuccin.groups.integrations.bufferline").get(),
})
