require("pluginmgr").add_plugin({
    src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    data = {
        event = { "FileType" },
        pattern = "markdown",
        config = function()
            setup_md()
        end,
    },
})

function setup_md()
    require("render-markdown").setup()
end
