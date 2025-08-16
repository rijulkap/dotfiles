local setup_md

require("pluginmgr").add_normal_spec({ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

require("pluginmgr").add_normal_setup(function()
    setup_md()
end)

function setup_md()
    require("render-markdown").setup()
end
