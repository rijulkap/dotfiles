require("pluginmgr").add_plugin({
    src = "https://github.com/catppuccin/nvim",
    data = {
        config = function()
            setup_colorcheme()
        end,
    },
})

-- now define the function
function setup_colorcheme()
    require("catppuccin").setup({
        integrations = {
            dashboard = true,
            fzf = true,
            gitsigns = true,
            mason = true,
            markdown = true,
            render_markdown = true,
            mini = true,
            native_lsp = {
                enabled = true,
                virtual_text = {
                    errors = { "italic" },
                    hints = { "italic" },
                    warnings = { "italic" },
                    information = { "italic" },
                    ok = { "italic" },
                },
                underlines = {
                    errors = { "undercurl" },
                    hints = { "undercurl" },
                    warnings = { "undercurl" },
                    information = { "undercurl" },
                },
                inlay_hints = { background = true },
            },
            notify = true,
            snacks = true,
            treesitter = true,
            treesitter_context = true,
            which_key = true,
            blink_cmp = true,
        },
        custom_highlights = function(colors)
            return {
                WinbarSeparatorDim = { fg = colors.overlay1, bg = "NONE" },
            }
        end,
    })

    vim.cmd.colorscheme("catppuccin")
end
