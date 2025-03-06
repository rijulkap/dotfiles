return {
    {
        -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
        opts = {
            preset = "helix",
        },
        config = function(_, opts) -- This is the function that runs, AFTER loading
            require('which-key').setup(opts)

            -- Document existing key chains
            require('which-key').add {
                { '<leader>l', group = '[l]sp Stuff' },
                { '<leader>s', group = '[S]earch' },
                { '<leader>b', group = '[b]uffer menu' },
            }
        end,
    },
}
