return {
    { -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "nvim-treesitter/nvim-treesitter-context"
        },
        opts = {
            ensure_installed = { 'bash', 'c', 'cpp', 'c_sharp', 'python', 'rust', 'json', 'markdown', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
            auto_install = true,
            highlight = {
                enable = true,
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ['af'] = '@function.outer',
                        ['if'] = '@function.inner',
                        ['ac'] = '@class.outer',
                        ['ic'] = '@class.inner',
                        ['a,'] = '@parameter.outer',
                        ['i,'] = '@parameter.inner',
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        [']f'] = '@function.outer',
                        [']c'] = '@class.outer',
                        ['],'] = '@parameter.inner',
                    },
                    goto_next_end = {
                        [']F'] = '@function.outer',
                        [']C'] = '@class.outer',
                    },
                    goto_previous_start = {
                        ['[f'] = '@function.outer',
                        ['[c'] = '@class.outer',
                        ['[,'] = '@parameter.inner',
                    },
                    goto_previous_end = {
                        ['[F'] = '@function.outer',
                        ['[C'] = '@class.outer',
                    },
                },
                swap = {
                    enable = true,
                    swap_next = { ['>,'] = '@parameter.inner' },
                    swap_previous = { ['<,'] = '@parameter.inner' },
                },
            },
            indent = { enable = true },
        },
        config = function(_, opts)
            ---@diagnostic disable-next-line: missing-fields
            require('nvim-treesitter.configs').setup(opts)
            vim.opt.foldmethod = 'expr'
            --
            -- -- :h vim.treesitter.foldexpr()
            vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
            --
            -- -- ref: https://github.com/neovim/neovim/pull/20750
            vim.opt.foldtext = ''
            vim.opt.fillchars:append 'fold: '
            --
            -- -- Open all folds by default, zm is not available
            vim.opt.foldlevelstart = 99
        end,
    },
}
