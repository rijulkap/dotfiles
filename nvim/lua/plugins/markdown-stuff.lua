local setup_md

require("pluginmgr").add_lazy_spec({ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

require("pluginmgr").pack_setup_on_filetype("markdown", "render-markdown.nvim", function()
    setup_md()
end)

function setup_md()
    require("render-markdown").setup()
end
