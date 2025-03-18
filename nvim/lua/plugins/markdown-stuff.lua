return {
    -- {
    --     'iamcco/markdown-preview.nvim',
    --     -- cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    --     ft = { 'markdown' },
    --     config = function()
    --         vim.fn['mkdp#util#install']()
    --     end,
    -- },
    {
        'OXY2DEV/markview.nvim',
        lazy = false, -- Recommended
        -- ft = "markdown" -- If you decide to lazy-load anyway

        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
    },
}
