local utils = require("utils")
local diagnostic_icons = require("icons").diagnostics

local function format_rust_diagnostic(diagnostic)
    local icon = diagnostic_icons[vim.diagnostic.severity[diagnostic.severity]]
    local message = vim.trim(diagnostic.message:gsub("%s+", " "))

    if #message > 100 then
        message = message:sub(1, 100) .. "..."
    end

    return icon .. " " .. message
end

local function setup_rust_diagnostics(client)
    if client.name ~= "rust_analyzer" then
        return
    end

    local virtual_text = vim.diagnostic.config().virtual_text
    if virtual_text == false then
        return
    end

    virtual_text = type(virtual_text) == "table" and vim.deepcopy(virtual_text) or {}
    virtual_text.format = format_rust_diagnostic

    local function configure_namespace(is_pull, pull_id)
        local namespace = vim.lsp.diagnostic.get_namespace(client.id, is_pull, pull_id)
        vim.diagnostic.config({ virtual_text = virtual_text }, namespace)
    end

    configure_namespace(false)

    local provider = client.server_capabilities.diagnosticProvider
    local pull_id = type(provider) == "table" and provider.identifier or nil
    configure_namespace(true, pull_id)
end

utils.dyn_lsp_methods:add(setup_rust_diagnostics)

return {
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                -- Keep editor checks from contending with normal Cargo builds.
                -- Rust Analyzer uses a subdirectory of the existing target dir.
                targetDir = true,
            },
            completion = {
                callable = {
                    snippets = "add_parentheses",
                },
            },
            check = {
                -- Check the package containing the saved file, not every
                -- package in the Cargo workspace.
                workspace = false,
            },
            checkOnSave = true,
            diagnostics = {
                enable = true, -- keep LSP semantic diagnostics
            },
        },
    },
}
