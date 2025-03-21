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
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {},
        ft = { "markdown" },
    },
}
