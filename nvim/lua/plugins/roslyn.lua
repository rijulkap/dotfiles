local setup_roslyn

require("pluginmgr").add_plugin({
    src = "https://github.com/seblyng/roslyn.nvim",
    data = {
        config = function()
            setup_roslyn()
        end,
    },
})

setup_roslyn = function()
    require("roslyn").setup({
        -- broad_search = true,
        lock_target = true,
    })
end
