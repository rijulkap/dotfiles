local utils = require("utils")

local diag_signs = require("icons").diagnostics

local document_highlight_group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = true })
local lsp_detach_group = vim.api.nvim_create_augroup("LspDetach", { clear = true })
local document_highlight_buffers = {}

local function setup_document_highlight(client, bufnr)
    if
        client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
        and not document_highlight_buffers[bufnr]
    then
        document_highlight_buffers[bufnr] = true

        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = document_highlight_group,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave", "WinLeave" }, {
            group = document_highlight_group,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
        })
    end
end

vim.api.nvim_create_autocmd("LspDetach", {
    group = lsp_detach_group,
    callback = function(event)
        vim.schedule(function()
            local has_highlight_client = vim.iter(vim.lsp.get_clients({ bufnr = event.buf })):any(function(client)
                return client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
            end)

            if not vim.api.nvim_buf_is_valid(event.buf) then
                return
            end

            if not has_highlight_client then
                vim.lsp.util.buf_clear_references(event.buf)
                vim.api.nvim_clear_autocmds({ group = document_highlight_group, buffer = event.buf })
                document_highlight_buffers[event.buf] = nil
            end
        end)
    end,
})

local function setup_inlayhint(client, bufnr)
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
end

local function setup_lsp_folding(client, bufnr)
    if client:supports_method("textDocument/foldingRange") then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == bufnr then
                vim.wo[win].foldmethod = "expr"
                vim.wo[win].foldexpr = "v:lua.vim.lsp.foldexpr()"
            end
        end
    end
end

utils.dyn_lsp_methods:add(setup_document_highlight)
vim.lsp.codelens.enable(false)
utils.dyn_lsp_methods:add(setup_inlayhint)
utils.dyn_lsp_methods:add(setup_lsp_folding)

local function update_loclist(opts)
    opts = opts or {}

    local diagnostics = vim.diagnostic.get(0, {
        severity = { min = opts.severity },
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
            lnum = diag.lnum + 1,
            col = diag.col + 1,
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
        severity = { min = opts.severity },
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
            col = diag.col + 1,   -- Same for columns
            text = prefix .. diag.message,
            severity = diag.severity,
        })
    end

    vim.fn.setqflist({}, "r", {
        title = "Workspace Diagnostics",
        items = items,
    })
end

local function loclist_is_open()
    return vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
end

local function qflist_is_open()
    return vim.fn.getqflist({ winid = 0 }).winid ~= 0
end

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
            if loclist_is_open() then
                vim.cmd("lclose")
                return
            end
            update_loclist({ severity = vim.diagnostic.severity.WARN })
            vim.cmd("lopen")
        end

        map("<leader>ll", function()
            toggle_loclist()
        end, "Toggle loclist")

        local function toggle_qflist()
            if qflist_is_open() then
                vim.cmd("cclose")
                return
            end
            update_qflist({ severity = vim.diagnostic.severity.WARN })
            vim.cmd("copen")
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

-- Keep visible diagnostic lists in sync without rebuilding them for every
-- publication in a burst of diagnostic updates.
local diagnostic_refresh_generation = 0
vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function()
        diagnostic_refresh_generation = diagnostic_refresh_generation + 1
        local generation = diagnostic_refresh_generation
        local winid = vim.api.nvim_get_current_win()

        vim.defer_fn(function()
            if generation ~= diagnostic_refresh_generation then
                return
            end

            if vim.api.nvim_win_is_valid(winid) then
                vim.api.nvim_win_call(winid, function()
                    if loclist_is_open() then
                        update_loclist({ severity = vim.diagnostic.severity.WARN })
                    end
                end)
            end
            if qflist_is_open() then
                update_qflist({ severity = vim.diagnostic.severity.WARN })
            end
        end, 75)
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
        severity = { min = "ERROR" },
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
        severity = { min = "ERROR" },
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
        severity = { min = "HINT" },
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

---@class MasonLsp
---@field name string Native LSP config name
---@field Condition? fun(): boolean Whether Mason should install this LSP

-- LSPs Mason should install; mason-lspconfig enables installed servers.
---@type (string|MasonLsp)[]
vim.g.lsps = {
    "basedpyright",
    "clangd",
    "jsonls",
    "lua_ls",
    "ruff",
    "rust_analyzer",
    "tinymist",
    {
        name = "roslyn_ls",
        Condition = function()
            return vim.fn.executable("dotnet") == 1
        end,
    },
    "ts_ls",
}
