require("pluginmgr").add_plugin({
    src = "https://github.com/stevearc/oil.nvim",
    data = {
        config = function()
            setup_oil()
        end,
    },
})

function setup_oil()
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
end
