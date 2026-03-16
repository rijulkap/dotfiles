local setup_md

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

setup_md = function()
    require("render-markdown").setup()
end
