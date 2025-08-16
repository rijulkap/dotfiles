vim.pack.add({ { src = "https://github.com/stevearc/oil.nvim" } }, { confirm = false })
require("oil").setup({
    columns = {
        "icon",
    },
    view_options = {
        show_hidden = true,
    },
})

vim.keymap.set("n", "-", function()
    require("oil").open_float()
end, { desc = "Open parent directory" })
