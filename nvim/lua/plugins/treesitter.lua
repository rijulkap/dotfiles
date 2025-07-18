return {
    { -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter-context",
                opts = function()
                    vim.keymap.set("n", "[c", function()
                        require("treesitter-context").go_to_context(vim.v.count1)
                    end, { silent = true })
                    return {
                        -- max_lines = 10,
                    }
                end,
            },
        },
        opts = function()
            ---@diagnostic disable-next-line: missing-fields
            vim.opt.foldmethod = "expr"
            --
            -- -- :h vim.treesitter.foldexpr()
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            --
            -- -- ref: https://github.com/neovim/neovim/pull/20750
            vim.opt.foldtext = ""
            vim.opt.fillchars:append("fold: ")
            return {
                ensure_installed = {
                    "bash",
                    "c",
                    "cpp",
                    "c_sharp",
                    "python",
                    "rust",
                    "json",
                    "markdown",
                    "html",
                    "lua",
                    "luadoc",
                    "markdown",
                    "vim",
                    "vimdoc",
                    "javascript",
                    "typescript",
                    "tsx",
                },
                -- auto_install = true,
                highlight = {
                    enable = true,
                },
                indent = { enable = true },
            }
        end,
    },
}
