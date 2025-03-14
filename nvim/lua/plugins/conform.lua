return {
    { -- Autoformat
        'stevearc/conform.nvim',
        lazy = false,
        keys = {
            {
                '<leader>f',
                function()
                    require('conform').format { async = true, lsp_fallback = true }
                end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        opts = {
            notify_on_error = false,
            notify_no_formatters = true,
            -- format_on_save = function(bufnr)
            --   -- local disable_filetypes = { c = true, cpp = true }
            --   local disable_filetypes = {}
            --   return {
            --     timeout_ms = 500,
            --     lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
            --   }
            -- end,
            formatters_by_ft = {
                lua = { 'stylua' },
            },
        },
        config = function()
            require('conform').setup {
                formatters = {
                    stylua = {
                        prepend_args = { '--indent-type', 'Spaces', '--indent-width', '4' },
                    },
                },
            }
        end,
    },
}
