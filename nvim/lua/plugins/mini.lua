local function setup_mini()
    local mI = require("mini.icons")
    mI.setup()
    mI.mock_nvim_web_devicons()
    require("mini.ai").setup()
    require("mini.move").setup()
    require("mini.surround").setup()
    require("mini.pairs").setup()
end

require("pluginmgr").add_normal({ src = "https://github.com/echasnovski/mini.nvim" }, setup_mini)
