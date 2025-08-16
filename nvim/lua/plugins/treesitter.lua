vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" } }, { confirm = false })
require("treesitter-context").setup()
vim.keymap.set("n", "[c", function()
    require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })

vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } }, { confirm = false })

vim.opt.foldmethod = "expr"
--
-- -- :h vim.treesitter.foldexpr()
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
