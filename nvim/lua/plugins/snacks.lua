return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            terminal = {
                win = { position = "float" },
                keys = {
                    term_normal = {},
                },
            },
            explorer = { enabled = true },
            dashboard = {
                enabled = true,
                preset = {
                    keys = {
                        {
                            icon = " ",
                            key = "f",
                            desc = "Find File",
                            action = ":lua Snacks.dashboard.pick('files')",
                        },
                        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                        {
                            icon = " ",
                            key = "g",
                            desc = "Find Text",
                            action = ":lua Snacks.dashboard.pick('live_grep')",
                        },
                        {
                            icon = " ",
                            key = "r",
                            desc = "Recent Files",
                            action = ":lua Snacks.dashboard.pick('oldfiles')",
                        },
                        {
                            icon = "󱚈 ",
                            key = "s",
                            desc = "Last CWD Session",
                            action = ':lua require("sessions").try_read_session()',
                        },
                        {
                            icon = " ",
                            key = "c",
                            desc = "Config",
                            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
                        },
                        {
                            icon = "󰒲 ",
                            key = "L",
                            desc = "Lazy",
                            action = ":Lazy",
                            enabled = package.loaded.lazy ~= nil,
                        },
                        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                    },
                    -- Used by the `header` section
                    header = table.concat({
                        [[NEO-VIM]],
                        [[                                                ]],
                        [[                                          _.oo. ]],
                        [[                  _.u[[/;:,.         .odMMMMMM' ]],
                        [[               .o888UU[[[/;:-.  .o@P^    MMM^   ]],
                        [[              oN88888UU[[[/;::-.        dP^     ]],
                        [[             dNMMNN888UU[[[/;:--.   .o@P^       ]],
                        [[            ,MMMMMMN888UU[[/;::-. o@^           ]],
                        [[            NNMMMNN888UU[[[/~.o@P^              ]],
                        [[            888888888UU[[[/o@^-..               ]],
                        [[           oI8888UU[[[/o@P^:--..                ]],
                        [[        .@^  YUU[[[/o@^;::---..                 ]],
                        [[      oMP     ^/o@P^;:::---..                   ]],
                        [[   .dMMM    .o@^ ^;::---...                     ]],
                        [[  dMMMMMMM@^`       `^^^^                       ]],
                        [[ YMMMUP^                                        ]],
                        [[  ^^                                            ]],
                        [[                                                ]],
                    }, "\n"),
                },
            },
            bigfile = { enabled = true },
            scroll = { enabled = false },
            indent = { enabled = true, animate = { enabled = false } },
            notifier = {
                enabled = true,
                timeout = 3000,
            },
            quickfile = { enabled = true },
            statuscolumn = { enabled = true, left = { "mark", "sign" }, right = { "fold", "git" } },
            words = { enabled = false },
            styles = {
                notification = {
                    wo = { wrap = true }, -- Wrap notifications
                },
            },
            picker = { enabled = true },
        },
        keys = {

            {
                "-",
                function()
                    Snacks.explorer.open({ diagnostics = false, git_status = false })
                end,
                desc = "Toggle explorer",
            },
            {
                "<leader>z",
                function()
                    Snacks.zen()
                end,
                desc = "Toggle Zen Mode",
            },
            {
                "<leader>Z",
                function()
                    Snacks.zen.zoom()
                end,
                desc = "Toggle Zoom",
            },
            {
                "<leader>.",
                function()
                    Snacks.scratch()
                end,
                desc = "Toggle Scratch Buffer",
            },
            {
                "<leader>S",
                function()
                    Snacks.scratch.select()
                end,
                desc = "Select Scratch Buffer",
            },
            {
                "<leader>n",
                function()
                    Snacks.notifier.show_history()
                end,
                desc = "Notification History",
            },
            {
                "<leader>bd",
                function()
                    Snacks.bufdelete()
                end,
                desc = "Delete Buffer",
            },
            {
                "<leader>cR",
                function()
                    Snacks.rename.rename_file()
                end,
                desc = "Rename File",
            },
            {
                "<leader>gB",
                function()
                    Snacks.gitbrowse()
                end,
                desc = "Git Browse",
            },
            {
                "<leader>gb",
                function()
                    Snacks.git.blame_line()
                end,
                desc = "Git Blame Line",
            },
            {
                "<leader>gf",
                function()
                    Snacks.lazygit.log_file()
                end,
                desc = "Lazygit Current File History",
            },
            {
                "<leader>gg",
                function()
                    Snacks.lazygit()
                end,
                desc = "Lazygit",
            },
            {
                "<leader>gl",
                function()
                    Snacks.lazygit.log()
                end,
                desc = "Lazygit Log (cwd)",
            },
            {
                "<leader>un",
                function()
                    Snacks.notifier.hide()
                end,
                desc = "Dismiss All Notifications",
            },
            {
                "<c-\\>",
                function()
                    Snacks.terminal(nil, {
                        env = { NAME = "FloatTerm1" },
                        win = {
                            wo = {
                                winbar = "FloatTerm1",
                            },
                        },
                    })
                end,
                desc = "Toggle Terminal1",
                mode = { "n", "t", "i" },
            },
            -- {
            --     "<A-2>",
            --     function()
            --         Snacks.terminal(nil, {
            --             env = { NAME = "FloatTerm2" },
            --             win = {
            --                 wo = {
            --                     winbar = "FloatTerm2",
            --                 },
            --             },
            --         })
            --     end,
            --     desc = "Toggle Terminal2",
            --     mode = { "n", "t", "i" },
            -- },
            {
                "]]",
                function()
                    Snacks.words.jump(vim.v.count1)
                end,
                desc = "Next Reference",
                mode = { "n", "t" },
            },
            {
                "[[",
                function()
                    Snacks.words.jump(-vim.v.count1)
                end,
                desc = "Prev Reference",
                mode = { "n", "t" },
            },

            {
                "<leader><leader>",
                function()
                    Snacks.picker.buffers({ current = true })
                end,
                desc = "Switch Buffer",
            },
            {
                "<leader>sg",
                function()
                    Snacks.picker.grep()
                end,
                desc = "Grep (Root Dir)",
            },
            {
                "<leader>:",
                function()
                    Snacks.picker.command_history()
                end,
                desc = "Command History",
            },
            {
                "<leader>sf",
                function()
                    Snacks.picker.files()
                end,
                desc = "Find Files (Root Dir)",
            },
            {
                "<leader>sF",
                function()
                    Snacks.picker.files({ hidden = true, ignored = true })
                end,
                desc = "Find All Files (Root Dir)",
            },
            -- find
            {
                "<leader>sn",
                function()
                    Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
                end,
                desc = "Find Config File",
            },
            {
                "<leader>s.",
                function()
                    Snacks.picker.recent()
                end,
                desc = "Recent",
            },
            -- git
            {
                "<leader>gc",
                function()
                    Snacks.picker.git_log()
                end,
                desc = "Commits",
            },
            {
                "<leader>gs",
                function()
                    Snacks.picker.git_status()
                end,
                desc = "Status",
            },
            -- search
            {
                '<leader>s"',
                function()
                    Snacks.picker.registers()
                end,
                desc = "Registers",
            },
            {
                "<leader>sa",
                function()
                    Snacks.picker.autocmds()
                end,
                desc = "Auto Commands",
            },
            {
                "<leader>sb",
                function()
                    Snacks.picker.lines()
                end,
                desc = "Buffer",
            },
            {
                "<leader>sc",
                function()
                    Snacks.picker.commands()
                end,
                desc = "Commands",
            },
            {
                "<leader>sd",
                function()
                    Snacks.picker.diagnostics_buffer()
                end,
                desc = "Document Diagnostics",
            },
            {
                "<leader>sD",
                function()
                    Snacks.picker.diagnostics()
                end,
                desc = "Workspace Diagnostics",
            },
            {
                "<leader>sh",
                function()
                    Snacks.picker.help()
                end,
                desc = "Help Pages",
            },
            {
                "<leader>sH",
                function()
                    Snacks.picker.highlights()
                end,
                desc = "Search Highlight Groups",
            },
            {
                "<leader>sj",
                function()
                    Snacks.picker.jumps()
                end,
                desc = "Jumplist",
            },
            {
                "<leader>sk",
                function()
                    Snacks.picker.keymaps()
                end,
                desc = "Key Maps",
            },
            {
                "<leader>sl",
                function()
                    Snacks.picker.loclist()
                end,
                desc = "Location List",
            },
            {
                "<leader>sM",
                function()
                    Snacks.picker.man()
                end,
                desc = "Man Pages",
            },
            {
                "<leader>sm",
                function()
                    Snacks.picker.marks()
                end,
                desc = "Jump to Mark",
            },
            {
                "<leader>sR",
                function()
                    Snacks.picker.resume()
                end,
                desc = "Resume",
            },
            {
                "<leader>sq",
                function()
                    Snacks.picker.qflist()
                end,
                desc = "Quickfix List",
            },
            {
                "<leader>ss",
                function()
                    Snacks.picker.lsp_symbols()
                end,
                desc = "Goto Symbol",
            },
            {
                "<leader>sS",
                function()
                    Snacks.picker.lsp_workspace_symbols()
                end,
                desc = "Goto Symbol (Workspace)",
            },
            {
                "<leader>su",
                function()
                    Snacks.picker.undo()
                end,
                desc = "Undo History",
            },
            {
                "<leader>sC",
                function()
                    Snacks.picker.colorschemes()
                end,
                desc = "Colorschemes",
            },
        },
        init = function()
            vim.keymap.set({ "t" }, "<esc><esc>", "<C-\\><C-n>")

            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                callback = function()
                    -- Setup some globals for debugging (lazy-loaded)
                    _G.dd = function(...)
                        Snacks.debug.inspect(...)
                    end
                    _G.bt = function()
                        Snacks.debug.backtrace()
                    end
                    vim.print = _G.dd -- Override print to use snacks for `:=` command

                    -- Create some toggle mappings
                    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
                    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
                    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
                    Snacks.toggle.diagnostics():map("<leader>ud")
                    Snacks.toggle.line_number():map("<leader>ul")
                    Snacks.toggle
                        .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
                        :map("<leader>uc")
                    Snacks.toggle.treesitter():map("<leader>uT")
                    Snacks.toggle
                        .option("background", { off = "light", on = "dark", name = "Dark Background" })
                        :map("<leader>ub")
                    Snacks.toggle.inlay_hints():map("<leader>uh")
                end,
            })
        end,
    },
}
