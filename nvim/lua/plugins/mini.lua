return {
    { -- Collection of various small independent plugins/modules
        "echasnovski/mini.nvim",
        config = function()
            local mI = require("mini.icons")
            mI.setup()
            mI.mock_nvim_web_devicons()
            require("mini.ai").setup()
            require("mini.move").setup()
            require("mini.surround").setup()
            require("mini.pairs").setup()
            require("mini.sessions").setup({ file = "" })
            vim.keymap.set("n", "<leader>q", function()
                require("mini.sessions").write(require("sessions").get_hashed_session_name())
                vim.cmd("wqa")
            end, { desc = "Save Session and quit" })
        end,
    },
}
