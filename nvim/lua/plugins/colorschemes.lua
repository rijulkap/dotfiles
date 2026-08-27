local setup_colorcheme

require("pluginmgr").add_plugin({
    src = "https://github.com/catppuccin/nvim",
    data = {
        config = function()
            setup_colorcheme()
        end,
    },
})

-- now define the function
setup_colorcheme = function()
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
                NormalNC = { fg = colors.text, bg = colors.mantle },
                WinSeparator = { fg = colors.surface1 },

                StatuslineModeNormal = { fg = colors.blue, bg = colors.mantle, bold = true },
                StatuslineModeInsert = { fg = colors.green, bg = colors.mantle, bold = true },
                StatuslineModeVisual = { fg = colors.mauve, bg = colors.mantle, bold = true },
                StatuslineModeCommand = { fg = colors.peach, bg = colors.mantle, bold = true },
                StatuslineModePending = { fg = colors.yellow, bg = colors.mantle, bold = true },
                StatuslineModeOther = { fg = colors.teal, bg = colors.mantle, bold = true },
                StatuslineTitle = { fg = colors.lavender, bold = true },

                WinBar = { fg = colors.blue, bg = colors.crust },
                WinBarDir = { fg = colors.lavender, bg = colors.crust, bold = true },
                WinBarFile = { fg = colors.peach, bg = colors.crust, bold = true },
                WinbarSeparatorDim = { fg = colors.overlay1, bg = "NONE" },
            }
        end,
    })

    vim.cmd.colorscheme("catppuccin")
end
