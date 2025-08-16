require("plugins.init")

vim.keymap.set("n", "<leader>up", function()
    vim.pack.update()
end, { desc = "Update all plugins" })
