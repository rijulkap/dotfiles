local setup_mini

require("pluginmgr").add_plugin({
    src = "https://github.com/nvim-mini/mini.nvim",
    data = {
        config = function()
            setup_mini()
        end,
    },
})

setup_mini = function()
    local mI = require("mini.icons")
    mI.setup()
    mI.mock_nvim_web_devicons()
    require("mini.ai").setup()
    require("mini.move").setup()
    require("mini.surround").setup()
    require("mini.pairs").setup({
        modes = { insert = true, command = true, terminal = false },
        -- skip autopair when next character is one of these
        skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
        -- skip autopair when the cursor is inside these treesitter nodes
        skip_ts = { "string" },
        -- skip autopair when next character is closing pair
        -- and there are more closing pairs than opening pairs
        skip_unbalanced = true,
        -- better deal with markdown code blocks
        markdown = true,
    })
end
