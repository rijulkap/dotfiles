return {
    {
        "stevearc/oil.nvim",
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
        opts = function(_)
            vim.keymap.set("n", "-", function()
                require("oil").open_float()
            end, { desc = "Open parent directory" })
            return {
                columns = {
                    "icon",
                },
                view_options = {
                    show_hidden = true,
                },
            }
        end,
    },
}
