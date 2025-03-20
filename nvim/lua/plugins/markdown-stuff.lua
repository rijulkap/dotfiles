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
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
        opts = {},
        ft = { 'markdown' },
    },
}
