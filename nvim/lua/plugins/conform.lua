vim.g.formatters = { "stylua" }

vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim" } }, { confirm = false })
require("conform").setup({
    notify_on_error = false,
    format_on_save = function(bufnr)
        if vim.g.autoformat then
            -- local disable_filetypes = { c = true, cpp = true }
            local disable_filetypes = {}
            local lsp_format_opt
            if disable_filetypes[vim.bo[bufnr].filetype] then
                lsp_format_opt = "never"
            else
                lsp_format_opt = "fallback"
            end

            if vim.api.nvim_buf_line_count(bufnr) >= 2000 then
                vim.notify("Format on save Aborted: Large file")
                return false
            else
                return {
                    timeout_ms = 500,
                    lsp_format = lsp_format_opt,
                }
            end
        else
            return
        end
    end,
    formatters_by_ft = {
        lua = { "stylua" },
    },
    formatters = {
        stylua = {
            -- prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
            prepend_args = { "--indent-type", "Spaces" },
        },
    },
})
vim.keymap.set("n", "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "[F]ormat buffer" })

vim.g.autoformat = false

require("snacks").toggle
    .new({
        id = "Format on Save",
        name = "Format on Save",
        get = function()
            return vim.g.autoformat
        end,
        set = function(_)
            vim.g.autoformat = not vim.g.autoformat
        end,
    })
    :map("<leader>uf")
