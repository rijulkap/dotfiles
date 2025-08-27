require("pluginmgr").add_plugin({
    src = "https://github.com/nvim-treesitter/nvim-treesitter-context",
    data = {
        config = function()
            setup_ts_context()
        end,
    },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
    data = {
        config = function()
            setup_ts()
        end,
    },
})

function setup_ts_context()
    require("treesitter-context").setup()
    vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true })
end

function setup_ts()
    vim.opt.foldmethod = "expr"
    --
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    --
    -- -- ref: https://github.com/neovim/neovim/pull/20750
    vim.opt.foldtext = ""
    vim.opt.fillchars:append("fold: ")

    require("nvim-treesitter").setup({
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
    })
end
