vim.pack.add({ { src = "https://github.com/echasnovski/mini.nvim" } }, { confirm = false })

local mI = require("mini.icons")
mI.setup()
mI.mock_nvim_web_devicons()
require("mini.ai").setup()
require("mini.move").setup()
require("mini.surround").setup()
require("mini.pairs").setup()
