vim.pack.add({ { src = "https://github.com/folke/which-key.nvim" } }, { confirm = false })
local function setup_which_key()
    require("which-key").setup({
        preset = "helix",
    })

    require("which-key").add({
        { "<leader>l", group = "[l]sp Stuff" },
        { "<leader>s", group = "[S]earch" },
        { "<leader>b", group = "[b]uffer menu" },
    })
end
require("pluginmgr").add_normal({ src = "https://github.com/folke/which-key.nvim" }, setup_which_key)
