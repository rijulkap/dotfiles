require("pluginmgr").add_plugin({
    src = "https://github.com/folke/flash.nvim",
    data = { config =function() setup_flash() end },
})

function setup_flash()
    require("flash").setup()

    vim.keymap.set({ "n", "x", "o" }, "s", function()
        require("flash").jump()
    end, { desc = "Flash" })

    vim.keymap.set({ "n", "x", "o" }, "S", function()
        require("flash").treesitter()
    end, { desc = "Flash Treesitter" })

    vim.keymap.set("o", "R", function()
        require("flash").remote()
    end, { desc = "Remote Flash" })

    vim.keymap.set("c", "<c-s>", function()
        require("flash").toggle()
    end, { desc = "Toggle Flash Search" })
end
