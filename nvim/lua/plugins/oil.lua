return {
    {
        "stevearc/oil.nvim",
        -- Optional dependencies
        config = function(_)
            require("oil").setup({
                columns = {
                    "icon",
                },
            })
            vim.keymap.set("n", "-", function()
                require("oil").open_float()
            end, { noremap = true, silent = true, desc = "Open parent directory" })
        end,
    },
}
