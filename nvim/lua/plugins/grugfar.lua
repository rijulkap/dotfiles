local function setup_grugfar()
    require("grug-far").setup({})

    vim.keymap.set({ "n", "x" }, "<leader>sr", function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
            transient = true,
            prefills = {
                filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
        })
    end, { desc = "GrugFar - Search & Replace" })
end

require("pluginmgr").add_plugin({
    src = "https://github.com/MagicDuck/grug-far.nvim",
    data = {
        cmd = { "GrugFar", "GrugFarWithin" },
        keys = {
            {
                lhs = "<leader>sr",
                mode = { "n", "x" },
                desc = "GrugFar - Search & Replace",
            },
        },

        config = function()
            setup_grugfar()
        end,
    },
})
