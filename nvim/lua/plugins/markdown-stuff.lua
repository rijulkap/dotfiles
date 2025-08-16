local function setup_md()
    require("render-markdown").setup()
end

require("pluginmgr").add_normal(
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
    setup_md
)
