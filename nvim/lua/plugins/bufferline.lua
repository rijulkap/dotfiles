return {
    {
        'akinsho/bufferline.nvim',
        event = 'VeryLazy',
        keys = {
            { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle Pin' },
            { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete Non-Pinned Buffers' },
            { '<leader>br', '<Cmd>BufferLineCloseRight<CR>', desc = 'Delete Buffers to the Right' },
            { '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', desc = 'Delete Buffers to the Left' },
            { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
            { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
            { '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
            { ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
            { '[B', '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer prev' },
            { ']B', '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer next' },
        },
        opts = {
            options = {
                close_command = function(n)
                    Snacks.bufdelete(n)
                end,
                right_mouse_command = function(n)
                    Snacks.bufdelete(n)
                end,
                separator_style = 'slant',
                diagnostics = 'nvim_lsp',
                always_show_bufferline = false,
                diagnostics_indicator = function(_, _, diag)
                    local ret = (diag.error and ' ' .. diag.error .. ' ' or '') .. (diag.warning and ' ' .. diag.warning or '')
                    return vim.trim(ret)
                end,
                offsets = {
                    {
                        filetype = 'snacks_layout_box',
                    },
                },
            },
        },
        config = function(_, opts)
            require('bufferline').setup(opts)
        end,
    },
}
