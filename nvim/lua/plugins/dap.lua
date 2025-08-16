-- Set up icons.
local icons = {
    Stopped = { "", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = "",
    BreakpointCondition = "",
    BreakpointRejected = { "", "DiagnosticError" },
}
for name, sign in pairs(icons) do
    sign = type(sign) == "table" and sign or { sign }
    vim.fn.sign_define("Dap" .. name, {
        -- stylua: ignore
        text = sign[1] --[[@as string]] .. ' ',
        texthl = sign[2] or "DiagnosticInfo",
        linehl = sign[3],
        numhl = sign[3],
    })
end

require("utils").PackageManager:add({ src = "https://github.com/jay-babu/mason-nvim-dap.nvim" }, nil)

require("utils").PackageManager:add({ src = "https://github.com/mfussenegger/nvim-dap" }, nil)

local function setup_dap_view()
    local dap = require("dap")
end

require("utils").PackageManager:add({ src = "https://github.com/igorlfs/nvim-dap-view" }, nil)

require("dap-view").setup({
    winbar = {
        sections = { "scopes", "breakpoints", "threads", "exceptions", "repl", "console" },
        default_section = "scopes",
    },
    windows = { height = 18 },
    switchbuf = "usetab,uselast",
})

local dv = require("dap-view")

dap.listeners.before.attach["dap-view-config"] = function()
    dv.open()
end
dap.listeners.before.launch["dap-view-config"] = function()
    dv.open()
end
dap.listeners.before.event_terminated["dap-view-config"] = function()
    dv.close()
end
dap.listeners.before.event_exited["dap-view-config"] = function()
    dv.close()
end

local InstallLocation = require("mason-core.installer.InstallLocation")

-- Adapter: CoreCLR (.NET)
local netcoredbg_root = InstallLocation.global():package("netcoredbg")
local netcoredbg_exe = vim.fs.joinpath(netcoredbg_root, "netcoredbg", "netcoredbg.exe")

dap.adapters.coreclr = {
    type = "executable",
    command = netcoredbg_exe,
    args = { "--interpreter=vscode" },
    detached = false,
}

dap.configurations.cs = {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
        stopOnEntry = true,
    },
}

-- Adapter: CodeLLDB (Rust, C, C++)
local codelldb_root = InstallLocation.global():package("codelldb")
local codelldb_exe = vim.fs.joinpath(codelldb_root, "extension", "adapter", "codelldb")

dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
        command = codelldb_exe,
        args = { "--port", "${port}" },

        -- On windows you may have to uncomment this:
    },
    -- detached = false,
}

dap.configurations.rust = {
    {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}

dap.configurations.c = dap.configurations.rust
dap.configurations.cpp = dap.configurations.rust

vim.keymap.set("n", "<leader>dB", function()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Breakpoint Condition" })

vim.keymap.set("n", "<leader>db", function()
    require("dap").toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })

vim.keymap.set("n", "<leader>dc", function()
    require("dap").continue()
end, { desc = "Continue" })

vim.keymap.set("n", "<leader>dC", function()
    require("dap").run_to_cursor()
end, { desc = "Run to Cursor" })

vim.keymap.set("n", "<leader>dg", function()
    require("dap").goto_()
end, { desc = "Go to line (no execute)" })

vim.keymap.set("n", "<leader>di", function()
    require("dap").step_into()
end, { desc = "Step Into" })

vim.keymap.set("n", "<leader>dj", function()
    require("dap").down()
end, { desc = "Down" })

vim.keymap.set("n", "<leader>dk", function()
    require("dap").up()
end, { desc = "Up" })

vim.keymap.set("n", "<leader>dl", function()
    require("dap").run_last()
end, { desc = "Run Last" })

vim.keymap.set("n", "<leader>do", function()
    require("dap").step_out()
end, { desc = "Step Out" })

vim.keymap.set("n", "<leader>dO", function()
    require("dap").step_over()
end, { desc = "Step Over" })

vim.keymap.set("n", "<leader>dp", function()
    require("dap").pause()
end, { desc = "Pause" })

vim.keymap.set("n", "<leader>dr", function()
    require("dap").repl.toggle()
end, { desc = "Toggle REPL" })

vim.keymap.set("n", "<leader>ds", function()
    require("dap").session()
end, { desc = "Session" })

vim.keymap.set("n", "<leader>dt", function()
    require("dap").terminate()
end, { desc = "Terminate" })

vim.keymap.set("n", "<leader>du", function()
    require("dap-view").close(true)
end, { desc = "Close UI" })


local function setup_dap_vt()
    require("nvim-dap-virtual-text").setup({ virt_text_pos = "eol" })
end
require("utils").PackageManager:add({ src = "https://github.com/theHamsta/nvim-dap-virtual-text" }, setup_dap_vt)

