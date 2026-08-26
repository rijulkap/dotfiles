local function setup_codecompanion()
    require("codecompanion").setup({
        adapters = {
            acp = {
                codex = function()
                    return require("codecompanion.adapters").extend("codex", {
                        defaults = {
                            auth_method = "chat-gpt",
                        },
                    })
                end,
            },
        },
    })

    vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI: Open chat" })
    vim.keymap.set("v", "<leader>cc", "<cmd>CodeCompanionChat Add<cr>", { desc = "AI: Add selection to chat" })
end

require("pluginmgr").add_plugin({
    src = "https://github.com/nvim-lua/plenary.nvim",
    data = {
        lazy = true,
    },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/olimorris/codecompanion.nvim",
    version = vim.version.range("^19.0.0"),
    data = {
        dependencies = {
            "plenary.nvim",
        },

        cmd = {
            "CodeCompanionChat",
        },

        keys = {
            {
                lhs = "<leader>cc",
                mode = "n",
                desc = "AI: Open chat",
            },
            {
                lhs = "<leader>cc",
                mode = "v",
                desc = "AI: Add selection to chat",
            },
        },

        config = function()
            setup_codecompanion()
        end,
    },
})
