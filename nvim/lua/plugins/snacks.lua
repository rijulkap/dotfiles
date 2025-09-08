require("pluginmgr").add_plugin({
    src = "https://github.com/folke/snacks.nvim",
    data = {
        config = function()
            setup_snacks()
        end,
    },
})

function setup_snacks()
    local Snacks = require("snacks")
    Snacks.setup({
        terminal = {
            win = { position = "float" },
            keys = {
                term_normal = {},
            },
        },
        explorer = { enabled = true, replace_netrw = false },
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
                        icon = " ",
                        key = "c",
                        desc = "Config",
                        action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
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
            sections = {
                { section = "header" },
                { section = "keys", gap = 1, padding = 1 },
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
        picker = {
            enabled = false,
            formatters = {
                file = {
                    filename_first = true,
                },
            },
        },
    })

    vim.keymap.set("n", "_", function()
        Snacks.explorer.open({ diagnostics = false, git_status = false })
    end, { desc = "Toggle explorer" })

    -- Toggle Explorer
    vim.keymap.set("n", "_", function()
        Snacks.explorer.open({ diagnostics = false, git_status = false })
    end, { desc = "Toggle explorer" })

    -- Zen / Scratch / Notifications / Buffers
    vim.keymap.set("n", "<leader>z", function()
        Snacks.zen()
    end, { desc = "Toggle Zen Mode" })
    vim.keymap.set("n", "<leader>Z", function()
        Snacks.zen.zoom()
    end, { desc = "Toggle Zoom" })
    vim.keymap.set("n", "<leader>.", function()
        Snacks.scratch()
    end, { desc = "Toggle Scratch Buffer" })
    vim.keymap.set("n", "<leader>S", function()
        Snacks.scratch.select()
    end, { desc = "Select Scratch Buffer" })
    vim.keymap.set("n", "<leader>n", function()
        Snacks.notifier.show_history()
    end, { desc = "Notification History" })
    vim.keymap.set("n", "<leader>bd", function()
        Snacks.bufdelete()
    end, { desc = "Delete Buffer" })
    vim.keymap.set("n", "<leader>bD", function()
        Snacks.bufdelete.other()
    end, { desc = "Delete Other Buffers" })
    vim.keymap.set("n", "<leader>cR", function()
        Snacks.rename.rename_file()
    end, { desc = "Rename File" })

    -- Git
    vim.keymap.set("n", "<leader>gB", function()
        Snacks.gitbrowse()
    end, { desc = "Git Browse" })
    vim.keymap.set("n", "<leader>gb", function()
        Snacks.git.blame_line()
    end, { desc = "Git Blame Line" })
    vim.keymap.set("n", "<leader>gf", function()
        Snacks.lazygit.log_file()
    end, { desc = "Lazygit Current File History" })
    vim.keymap.set("n", "<leader>gg", function()
        Snacks.lazygit()
    end, { desc = "Lazygit" })
    vim.keymap.set("n", "<leader>gl", function()
        Snacks.lazygit.log()
    end, { desc = "Lazygit Log (cwd)" })

    -- Notifications
    vim.keymap.set("n", "<leader>un", function()
        Snacks.notifier.hide()
    end, { desc = "Dismiss All Notifications" })

    -- Terminal
    vim.keymap.set({ "n", "t", "i" }, "<c-\\>", function()
        Snacks.terminal(nil, {
            env = { NAME = "FloatTerm1" },
            win = { wo = { winbar = "FloatTerm1" } },
        })
    end, { desc = "Toggle Terminal1" })

    vim.keymap.set({ "t" }, "<esc><esc>", "<C-\\><C-n>")

    -- References
    vim.keymap.set({ "n", "t" }, "]]", function()
        Snacks.words.jump(vim.v.count1)
    end, { desc = "Next Reference" })
    vim.keymap.set({ "n", "t" }, "[[", function()
        Snacks.words.jump(-vim.v.count1)
    end, { desc = "Prev Reference" })

    -- Buffers / Search / Pickers
    -- vim.keymap.set("n", "<leader><leader>", function()
    --     Snacks.picker.buffers({ current = true })
    -- end, { desc = "Switch Buffer" })
    -- vim.keymap.set("n", "<leader>sg", function()
    --     Snacks.picker.grep()
    -- end, { desc = "Grep (Root Dir)" })
    -- vim.keymap.set("n", "<leader>:", function()
    --     Snacks.picker.command_history()
    -- end, { desc = "Command History" })
    -- vim.keymap.set("n", "<leader>sf", function()
    --     Snacks.picker.files()
    -- end, { desc = "Find Files (Root Dir)" })
    -- vim.keymap.set("n", "<leader>sF", function()
    --     Snacks.picker.files({ hidden = true, ignored = true })
    -- end, { desc = "Find All Files (Root Dir)" })
    -- vim.keymap.set("n", "<leader>sn", function()
    --     Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
    -- end, { desc = "Find Config File" })
    -- vim.keymap.set("n", "<leader>s.", function()
    --     Snacks.picker.recent()
    -- end, { desc = "Recent" })
    --
    -- -- Git Pickers
    -- vim.keymap.set("n", "<leader>gc", function()
    --     Snacks.picker.git_log()
    -- end, { desc = "Commits" })
    -- vim.keymap.set("n", "<leader>gs", function()
    --     Snacks.picker.git_status()
    -- end, { desc = "Status" })
    --
    -- -- Search Pickers
    -- vim.keymap.set("n", '<leader>s"', function()
    --     Snacks.picker.registers()
    -- end, { desc = "Registers" })
    -- vim.keymap.set("n", "<leader>sa", function()
    --     Snacks.picker.autocmds()
    -- end, { desc = "Auto Commands" })
    -- vim.keymap.set("n", "<leader>sb", function()
    --     Snacks.picker.lines()
    -- end, { desc = "Buffer" })
    -- vim.keymap.set("n", "<leader>sc", function()
    --     Snacks.picker.commands()
    -- end, { desc = "Commands" })
    -- vim.keymap.set("n", "<leader>sd", function()
    --     Snacks.picker.diagnostics_buffer()
    -- end, { desc = "Document Diagnostics" })
    -- vim.keymap.set("n", "<leader>sD", function()
    --     Snacks.picker.diagnostics()
    -- end, { desc = "Workspace Diagnostics" })
    -- vim.keymap.set("n", "<leader>sh", function()
    --     Snacks.picker.help()
    -- end, { desc = "Help Pages" })
    -- vim.keymap.set("n", "<leader>sH", function()
    --     Snacks.picker.highlights()
    -- end, { desc = "Search Highlight Groups" })
    -- vim.keymap.set("n", "<leader>sj", function()
    --     Snacks.picker.jumps()
    -- end, { desc = "Jumplist" })
    -- vim.keymap.set("n", "<leader>sk", function()
    --     Snacks.picker.keymaps()
    -- end, { desc = "Key Maps" })
    -- vim.keymap.set("n", "<leader>sl", function()
    --     Snacks.picker.loclist()
    -- end, { desc = "Location List" })
    -- vim.keymap.set("n", "<leader>sM", function()
    --     Snacks.picker.man()
    -- end, { desc = "Man Pages" })
    -- vim.keymap.set("n", "<leader>sm", function()
    --     Snacks.picker.marks()
    -- end, { desc = "Jump to Mark" })
    -- vim.keymap.set("n", "<leader>sR", function()
    --     Snacks.picker.resume()
    -- end, { desc = "Resume" })
    -- vim.keymap.set("n", "<leader>sq", function()
    --     Snacks.picker.qflist()
    -- end, { desc = "Quickfix List" })
    -- vim.keymap.set("n", "<leader>ss", function()
    --     Snacks.picker.lsp_symbols()
    -- end, { desc = "Goto Symbol" })
    -- vim.keymap.set("n", "<leader>sS", function()
    --     Snacks.picker.lsp_workspace_symbols()
    -- end, { desc = "Goto Symbol (Workspace)" })
    -- vim.keymap.set("n", "<leader>su", function()
    --     Snacks.picker.undo()
    -- end, { desc = "Undo History" })
    -- vim.keymap.set("n", "<leader>sC", function()
    --     Snacks.picker.colorschemes()
    -- end, { desc = "Colorschemes" })

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
    Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
    Snacks.toggle.inlay_hints():map("<leader>uh")
end
