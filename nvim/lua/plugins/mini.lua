local setup_mini

require("pluginmgr").add_normal_spec({ src = "https://github.com/echasnovski/mini.nvim" })
require("pluginmgr").add_normal_setup(function()
    setup_mini()
end)

function setup_mini()
    local mI = require("mini.icons")
    mI.setup()
    mI.mock_nvim_web_devicons()
    require("mini.ai").setup()
    require("mini.move").setup()
    require("mini.surround").setup()
    require("mini.pairs").setup()
end
