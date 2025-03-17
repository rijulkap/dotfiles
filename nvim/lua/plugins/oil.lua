return {
    {
        'stevearc/oil.nvim',
        opts = {
            columns = {
                'icon',
            },
        },
        -- Optional dependencies
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function(_, opts)
            require('oil').setup(opts)
            vim.keymap.set('n', '-', function()
                require('oil').open_float()
            end, { noremap = true, silent = true, desc = 'Open parent directory' })
        end,
    },
}
