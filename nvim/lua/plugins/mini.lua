return {
    { -- Collection of various small independent plugins/modules
        'echasnovski/mini.nvim',
        config = function()
            require('mini.move').setup()
            require('mini.surround').setup()
        end,
    },
}
