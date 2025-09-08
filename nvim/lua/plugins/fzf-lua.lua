require("pluginmgr").add_plugin({
    src = "https://github.com/ibhagwan/fzf-lua",
    data = {
        config = function()
            setup_fzf()
        end,
    },
})

function setup_fzf()
    require("fzf-lua").setup({
        defaults = {
            formatter = "path.filename_first",
        },
        diagnostics = {
            severity_limit = vim.diagnostic.severity.WARN,
            multiline = 3
        },
        marks = {
            marks = "%a", -- filter vim marks with a lua pattern
        },
    })

    local fzf = require("fzf-lua")

    vim.keymap.set("n", "<leader><leader>", function()
        fzf.buffers()
    end, { desc = "Switch Buffer" })
    vim.keymap.set("n", "<leader>sg", function()
        fzf.live_grep()
    end, { desc = "Grep (Root Dir)" })
    vim.keymap.set("n", "<leader>:", function()
        fzf.command_history()
    end, { desc = "Command History" })
    vim.keymap.set("n", "<leader>sf", function()
        fzf.files()
    end, { desc = "Find Files (Root Dir)" })
    vim.keymap.set("n", "<leader>sn", function()
        fzf.files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "Find Config File" })
    vim.keymap.set("n", "<leader>s.", function()
        fzf.recent()
    end, { desc = "Recent" })

    -- Git Pickers
    vim.keymap.set("n", "<leader>gc", function()
        fzf.git_commits()
    end, { desc = "Commits" })
    vim.keymap.set("n", "<leader>gs", function()
        fzf.git_status()
    end, { desc = "Status" })

    -- Search Pickers
    vim.keymap.set("n", '<leader>s"', function()
        fzf.registers()
    end, { desc = "Registers" })
    vim.keymap.set("n", "<leader>sa", function()
        fzf.autocmds()
    end, { desc = "Auto Commands" })
    vim.keymap.set("n", "<leader>sb", function()
        fzf.lines()
    end, { desc = "Buffer" })
    vim.keymap.set("n", "<leader>sc", function()
        fzf.commands()
    end, { desc = "Commands" })
    vim.keymap.set("n", "<leader>sd", function()
        fzf.diagnostics_document()
    end, { desc = "Document Diagnostics" })
    vim.keymap.set("n", "<leader>sD", function()
        fzf.diagnostics_workspace()
    end, { desc = "Workspace Diagnostics" })
    vim.keymap.set("n", "<leader>sh", function()
        fzf.helptags()
    end, { desc = "Help Pages" })
    vim.keymap.set("n", "<leader>sH", function()
        fzf.highlights()
    end, { desc = "Search Highlight Groups" })
    vim.keymap.set("n", "<leader>sj", function()
        fzf.jumps()
    end, { desc = "Jumplist" })
    vim.keymap.set("n", "<leader>sk", function()
        fzf.keymaps()
    end, { desc = "Key Maps" })
    vim.keymap.set("n", "<leader>sl", function()
        fzf.loclist()
    end, { desc = "Location List" })
    vim.keymap.set("n", "<leader>sM", function()
        fzf.man_pages()
    end, { desc = "Man Pages" })
    vim.keymap.set("n", "<leader>sm", function()
        fzf.marks()
    end, { desc = "Jump to Mark" })
    vim.keymap.set("n", "<leader>sR", function()
        fzf.resume()
    end, { desc = "Resume" })
    vim.keymap.set("n", "<leader>sq", function()
        fzf.quickfix()
    end, { desc = "Quickfix List" })
    vim.keymap.set("n", "<leader>ss", function()
        fzf.lsp_document_symbols()
    end, { desc = "Goto Symbol" })
    vim.keymap.set("n", "<leader>sS", function()
        fzf.lsp_workspace_symbols()
    end, { desc = "Goto Symbol (Workspace)" })
    vim.keymap.set("n", "<leader>sC", function()
        fzf.colorschemes()
    end, { desc = "Colorschemes" })
    vim.keymap.set("n", "<leader>sz", function()
        fzf.spell_suggest()
    end, { desc = "Spelling Suggest" })
    vim.keymap.set("n", "<leader>sp", function()
        fzf.packadd()
    end, { desc = "Spelling Suggest" })
end
