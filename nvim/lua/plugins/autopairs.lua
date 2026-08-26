local setup_autopair

require("pluginmgr").add_plugin({
    src = "https://github.com/windwp/nvim-autopairs",
    data = {
        event = { "InsertEnter" },
        config = function()
            setup_autopair()
        end,
    },
})

setup_autopair = function()
    require("nvim-autopairs").setup()
end
