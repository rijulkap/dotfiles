local setup_oil

require("pluginmgr").add_normal_spec({ src = "https://github.com/stevearc/oil.nvim" })

require("pluginmgr").add_normal_setup(function()
    setup_oil()
end)

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
