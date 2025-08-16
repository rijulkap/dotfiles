local setup_which_key

require("pluginmgr").add_normal_spec({ src = "https://github.com/folke/which-key.nvim" })
require("pluginmgr").add_normal_setup(function()
    setup_which_key()
end)

function setup_which_key()
    require("which-key").setup({
        preset = "helix",
    })

    require("which-key").add({
        { "<leader>l", group = "[l]sp Stuff" },
        { "<leader>s", group = "[S]earch" },
        { "<leader>b", group = "[b]uffer menu" },
    })
end
