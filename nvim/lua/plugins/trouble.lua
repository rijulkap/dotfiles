return {
    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        config = function(_, opts)
            require("trouble").setup(opts)
        end,
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
            -- {
            --     '<c-k>',
            --     function()
            --         if require('trouble').is_open() then
            --             require('trouble').prev { skip_groups = true, jump = true }
            --         elseif vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
            --             local ok, err = pcall(vim.cmd.lprev)
            --             if not ok then
            --                 vim.notify(err, vim.log.levels.ERROR)
            --             end
            --         else
            --             local ok, err = pcall(vim.cmd.cprev)
            --             if not ok then
            --                 vim.notify(err, vim.log.levels.ERROR)
            --             end
            --         end
            --     end,
            --     desc = 'Previous Trouble/Quickfix Item',
            -- },
            -- {
            --     '<c-j>',
            --     function()
            --         if require('trouble').is_open() then
            --             require('trouble').next { skip_groups = true, jump = true }
            --         elseif vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
            --             local ok, err = pcall(vim.cmd.lnext)
            --             if not ok then
            --                 vim.notify(err, vim.log.levels.ERROR)
            --             end
            --         else
            --             local ok, err = pcall(vim.cmd.cnext)
            --             if not ok then
            --                 vim.notify(err, vim.log.levels.ERROR)
            --             end
            --         end
            --     end,
            --     desc = 'Next Trouble/Quickfix Item',
            -- },
        },
    },
}
