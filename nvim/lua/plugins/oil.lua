local function setup_oil()
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

require("pluginmgr").add_normal({ src = "https://github.com/stevearc/oil.nvim" }, setup_oil)
