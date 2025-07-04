return {
    {
        "akinsho/bufferline.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
            { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
            { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
            { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
            { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
            { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
            { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
            { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
        },
        opts = {
            options = {
                tab_size = 25,
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
        },
    },
}
