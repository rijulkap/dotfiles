local function setup_dap()
    local dap = require("dap")
    local dap_view = require("dap-view")

    require("mason-nvim-dap").setup({
        ensure_installed = { "python", "codelldb", "coreclr", "js" },
        handlers = {},
    })

    require("nvim-dap-virtual-text").setup({
        virt_text_pos = "eol",
        highlight_changed_variables = true,
        show_stop_reason = true,
    })

    dap_view.setup({
        winbar = {
            sections = { "scopes", "breakpoints", "threads", "exceptions", "repl", "console" },
            default_section = "scopes",
        },
        windows = {
            size = 18,
            position = "below",
        },
        switchbuf = "usetab,uselast",
    })

    local listener = "dap-view-config"
    dap.listeners.before.attach[listener] = dap_view.open
    dap.listeners.before.launch[listener] = dap_view.open
    dap.listeners.before.event_terminated[listener] = function()
        dap_view.close(true)
    end
    dap.listeners.before.event_exited[listener] = function()
        dap_view.close(true)
    end

    local signs = {
        Breakpoint = { text = " ", texthl = "DiagnosticInfo" },
        BreakpointCondition = { text = " ", texthl = "DiagnosticWarn" },
        BreakpointRejected = { text = " ", texthl = "DiagnosticError" },
        LogPoint = { text = "󰛿 ", texthl = "DiagnosticInfo" },
        Stopped = { text = " ", texthl = "DiagnosticWarn", linehl = "DapStoppedLine" },
    }

    for name, sign in pairs(signs) do
        vim.fn.sign_define("Dap" .. name, sign)
    end

    vim.api.nvim_set_hl(0, "DapStoppedLine", { link = "Visual" })

    local loaded_launch_json
    local function load_launch_json()
        local path = vim.fs.joinpath(vim.fn.getcwd(), ".vscode", "launch.json")
        if path == loaded_launch_json or vim.fn.filereadable(path) == 0 then
            return
        end

        require("dap.ext.vscode").load_launchjs(path, {
            codelldb = { "c", "cpp", "rust" },
            coreclr = { "cs" },
            ["pwa-node"] = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            python = { "python" },
        })
        loaded_launch_json = path
    end

    local function continue()
        load_launch_json()
        dap.continue()
    end

    vim.api.nvim_create_user_command("DapStart", continue, { desc = "Start or continue debugging" })
    vim.api.nvim_create_user_command("DapStop", function()
        dap.terminate()
        dap_view.close(true)
    end, { desc = "Terminate debugging" })
    vim.api.nvim_create_user_command("DapToggleUI", dap_view.toggle, { desc = "Toggle debug UI" })

    local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = "Debug: " .. desc })
    end

    map("<F5>", continue, "Start/Continue")
    map("<F10>", dap.step_over, "Step Over")
    map("<F11>", dap.step_into, "Step Into")
    map("<S-F11>", dap.step_out, "Step Out")

    map("<leader>db", dap.toggle_breakpoint, "Toggle Breakpoint")
    map("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, "Conditional Breakpoint")
    map("<leader>dL", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end, "Log Point")
    map("<leader>dc", continue, "Start/Continue")
    map("<leader>dC", dap.run_to_cursor, "Run to Cursor")
    map("<leader>di", dap.step_into, "Step Into")
    map("<leader>do", dap.step_out, "Step Out")
    map("<leader>dO", dap.step_over, "Step Over")
    map("<leader>dp", dap.pause, "Pause")
    map("<leader>dj", dap.down, "Frame Down")
    map("<leader>dk", dap.up, "Frame Up")
    map("<leader>dl", dap.run_last, "Run Last")
    map("<leader>dr", dap.repl.toggle, "Toggle REPL")
    map("<leader>dt", function()
        dap.terminate()
        dap_view.close(true)
    end, "Terminate")
    map("<leader>du", dap_view.toggle, "Toggle UI")
    map("<leader>dh", require("dap.ui.widgets").hover, "Inspect")
end

require("pluginmgr").add_plugin({
    src = "https://github.com/mfussenegger/nvim-dap",
    data = { lazy = true },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/igorlfs/nvim-dap-view",
    version = vim.version.range("1.*"),
    data = { lazy = true },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/theHamsta/nvim-dap-virtual-text",
    data = { lazy = true },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/jay-babu/mason-nvim-dap.nvim",
    data = {
        dependencies = { "nvim-dap", "nvim-dap-view", "nvim-dap-virtual-text" },
        cmd = { "DapStart", "DapStop", "DapToggleUI" },
        keys = {
            { lhs = "<leader>db", desc = "Debug: Toggle Breakpoint" },
            { lhs = "<leader>dB", desc = "Debug: Conditional Breakpoint" },
            { lhs = "<leader>dc", desc = "Debug: Start/Continue" },
        },
        config = function()
            setup_dap()
        end,
    },
})
