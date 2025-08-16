vim.pack.add({ { src = "https://github.com/folke/which-key.nvim" } }, { confirm = false })

require("which-key").setup({
    preset = "helix",
})

require("which-key").add({
    { "<leader>l", group = "[l]sp Stuff" },
    { "<leader>s", group = "[S]earch" },
    { "<leader>b", group = "[b]uffer menu" },
})
