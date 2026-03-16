local setup_which_key

require("pluginmgr").add_plugin({
    src = "https://github.com/folke/which-key.nvim",
    data = {
        config = function()
            setup_which_key()
        end,
    },
})

setup_which_key = function()
    require("which-key").setup({
        preset = "helix",
    })

    require("which-key").add({
        { "<leader>l", group = "[l]sp Stuff" },
        { "<leader>s", group = "[S]earch" },
        { "<leader>b", group = "[b]uffer menu" },
    })
end
