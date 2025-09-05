local utils = require("utils")

local diag_signs = require("icons").diagnostics

local function setup_document_highlight(client, bufnr)
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        local highlight_augroup = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })

        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = highlight_augroup,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave", "WinLeave"}, {
            group = highlight_augroup,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
            callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "LspDocumentHighlight", buffer = event2.buf })
            end,
        })
    end
end

local function setup_codelens(client, bufnr)
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
        vim.lsp.codelens.refresh()
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = bufnr,
            callback = vim.lsp.codelens.refresh,
        })
    end
end

local function setup_inlayhint(client)
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        vim.lsp.inlay_hint.enable(true)
    end
end

utils.dyn_lsp_methods:add(setup_document_highlight)
-- utils.dyn_lsp_methods:add(setup_codelens)
utils.dyn_lsp_methods:add(setup_inlayhint)

local function update_loclist(opts)
    opts = opts or {}

    local diagnostics = vim.diagnostic.get(0, {
        severity = {min = opts.severity},
    })

    -- Format and sort by severity (ascending severity value = higher priority)
    table.sort(diagnostics, function(a, b)
        return a.severity < b.severity
    end)

    local items = {}
    for _, diag in ipairs(diagnostics) do
        local level = vim.diagnostic.severity[diag.severity]
        local prefix = string.format(" %s ", diag_signs[level])
        table.insert(items, {
            bufnr = diag.bufnr,
            lnum = diag.lnum,
            col = diag.col,
            text = prefix .. diag.message,
            severity = diag.severity,
        })
    end

    vim.fn.setloclist(0, {}, "r", {
        title = "Buffer Diagnostics",
        items = items,
    })
end

local function update_qflist(opts)
    opts = opts or {}

    local diagnostics = vim.diagnostic.get(nil, {
        severity = {min = opts.severity},
    })

    table.sort(diagnostics, function(a, b)
        return a.severity < b.severity
    end)

    local items = {}
    for _, diag in ipairs(diagnostics) do
        local level = vim.diagnostic.severity[diag.severity]
        local prefix = string.format(" %s ", diag_signs[level] or "")
        table.insert(items, {
            bufnr = diag.bufnr,
            lnum = diag.lnum + 1, -- Quickfix expects 1-based lines
            col = diag.col + 1, -- Same for columns
            text = prefix .. diag.message,
            severity = diag.severity,
        })
    end

    vim.fn.setqflist({}, "r", {
        title = "Workspace Diagnostics",
        items = items,
    })
end

vim.g.ll_open = false
vim.g.qf_open = false

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("gd", function()
            require("snacks").picker.lsp_definitions()
        end, "[G]oto [D]efinition")
        map("gD", function()
            require("snacks").picker.lsp_type_definitions()
        end, "[G]oto type [D]efinition")
        map("gr", function()
            require("snacks").picker.lsp_references()
        end, "[G]oto [R]eferences")
        map("gI", function()
            require("snacks").picker.lsp_implementations()
        end, "[G]oto [I]mplementation")

        local function toggle_loclist()
            if vim.g.ll_open == true then
                vim.cmd("lclose")
                vim.g.ll_open = false
                return
            end
            update_loclist({severity = vim.diagnostic.severity.WARN})
            vim.cmd("lopen")
            vim.g.ll_open = true
        end

        map("<leader>ll", function()
            toggle_loclist()
        end, "Toggle loclist")

        local function toggle_qflist()
            if vim.g.qf_open == true then
                vim.cmd("cclose")
                vim.g.qf_open = false
                return
            end
            update_qflist({severity = vim.diagnostic.severity.WARN})
            vim.cmd("copen")
            vim.g.qf_open = true
        end

        map("<leader>lq", function()
            toggle_qflist()
        end, "Toggle quickfix")

        map("<leader>lr", vim.lsp.buf.rename, "[l]sp [R]ename")
        map("<leader>lc", vim.lsp.buf.code_action, "[l]sp [C]ode Action")

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client then
            utils.dyn_lsp_methods:resolve(client, event.buf)
        end
    end,
})

-- Setup timer to refresh lists
vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function(args)
        if vim.g.ll_open then
            update_loclist({severity = vim.diagnostic.severity.WARN})
        end
        if vim.g.qf_open then
            update_qflist({severity = vim.diagnostic.severity.WARN})
        end
    end,
})

vim.lsp.log.set_level("off")

local hover = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
    return hover({
        border = "rounded",
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    })
end

local signature_help = vim.lsp.buf.signature_help
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.signature_help = function()
    return signature_help({
        border = "rounded",
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    })
end

local function truncate_message(message, max_length)
    if #message > max_length then
        return message:sub(1, max_length) .. "..."
    end
    return message
end

-- wrappers to allow for toggling
local def_virtual_text = {
    isTrue = {
        severity = { min = "WARN" },
        current_line = nil,
        prefix = "",
        -- source = "if_many",
        spacing = 2,
        format = function(diagnostic)
            local message = diag_signs[vim.diagnostic.severity[diagnostic.severity]] .. " "
            if diagnostic.source then
                message = string.format("%s %s", message, diagnostic.source)
            end
            if diagnostic.code then
                message = string.format("%s[%s]", message, diagnostic.code)
            end

            return message .. " "
        end,
    },
    isFalse = false,
}

local def_virtual_lines = {
    isTrue = {
        current_line = true,
        -- severity = { min = "ERROR" },
        format = function(diagnostic)
            local max_length = 100 -- Set your preferred max length
            return "● " .. truncate_message(diagnostic.message, max_length)
        end,
    },
    isFalse = false,
}

local default_diagnostic_config = {
    update_in_insert = false,
    virtual_lines = def_virtual_lines.isFalse,
    virtual_text = def_virtual_text.isTrue,
    underline = {
        severity = {min = "WARN"}
    },
    severity_sort = true,
    jump = {
        on_jump = vim.diagnostic.open_float,
    },
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = true,
        header = "",
        prefix = function(diag)
            local level = vim.diagnostic.severity[diag.severity]
            local prefix = string.format(" %s ", diag_signs[level])
            return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
        end,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg", -- Just cause its also bold
            [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
        },
    },
}

vim.diagnostic.config(default_diagnostic_config)

-- Override the virtual text diagnostic handler so that the most severe diagnostic is shown first.
local show_handler_vt = vim.diagnostic.handlers.virtual_text.show
assert(show_handler_vt)
local hide_handler = vim.diagnostic.handlers.virtual_text.hide
vim.diagnostic.handlers.virtual_text = {
    show = function(ns, bufnr, diagnostics, opts)
        table.sort(diagnostics, function(diag1, diag2)
            return diag1.severity > diag2.severity
        end)
        return show_handler_vt(ns, bufnr, diagnostics, opts)
    end,
    hide = hide_handler,
}

-- local datapath = vim.fn.stdpath("data")

vim.g.lsps = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
    :map(function(file)
        -- ignore all dynamically added lspconfig files
        -- if not vim.startswith(file, datapath) then
        return vim.fn.fnamemodify(file, ":t:r")
        -- end
    end)
    :totable()

-- Set Toggles
-- Snacks.toggle
--     .new({
--         id = "Virtual diagnostics (Lines)",
--         name = "Virtual diagnostics (Lines)",
--         get = function()
--             if vim.diagnostic.config().virtual_lines then
--                 return true
--             else
--                 return false
--             end
--         end,
--         set = function(state)
--             if state == true then
--                 vim.diagnostic.config({ virtual_lines = def_virtual_lines.isTrue })
--             else
--                 vim.diagnostic.config({ virtual_lines = def_virtual_lines.isFalse })
--             end
--         end,
--     })
--     :map("<leader>uvl")
--
-- Snacks.toggle
--     .new({
--         id = "Virtual diagnostics (Text)",
--         name = "Virtual diagnostics (Text)",
--         get = function()
--             if vim.diagnostic.config().virtual_text then
--                 return true
--             else
--                 return false
--             end
--         end,
--         set = function(state)
--             if state == true then
--                 vim.diagnostic.config({ virtual_text = def_virtual_text.isTrue })
--             else
--                 vim.diagnostic.config({ virtual_text = def_virtual_text.isFalse })
--             end
--         end,
--     })
--     :map("<leader>uvt")
