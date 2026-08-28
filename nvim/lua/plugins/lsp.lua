local setup_mason
local setup_mason_lspconfig
local setup_lspconfig
local setup_lazydev

local function lsp_entries()
    local entries = {}
    for _, entry in ipairs(vim.g.lsps or {}) do
        entries[#entries + 1] = type(entry) == "string" and { name = entry } or entry
    end
    return entries
end

local function mason_package_name(entry)
    if entry.package then
        return entry.package
    end

    local lsp_name = entry.replace or entry.name
    local mappings = require("mason-lspconfig").get_mappings()
    return mappings.lspconfig_to_package[lsp_name] or lsp_name
end

require("pluginmgr").add_plugin({
    src = "https://github.com/mason-org/mason.nvim",
    data = {
        event = "VimEnter",
        config = function()
            setup_mason()
        end,
    },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/neovim/nvim-lspconfig",
    data = {
        config = function()
            setup_lspconfig()
        end,
    },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/mason-org/mason-lspconfig.nvim",
    data = {
        dependencies = { "mason.nvim", "nvim-lspconfig" },
        config = function()
            setup_mason_lspconfig()
        end,
    },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/folke/lazydev.nvim",
    data = {
        event = { "FileType" },
        pattern = "lua",
        config = function()
            setup_lazydev()
        end,
    },
})

local function configured_tools()
    local tools = {}
    local seen = {}

    for _, entry in ipairs(lsp_entries()) do
        local package_name = mason_package_name(entry)
        if not seen[package_name] then
            seen[package_name] = true
            tools[#tools + 1] = package_name
        end
    end
    for _, name in ipairs(vim.g.formatters or {}) do
        if not seen[name] then
            seen[name] = true
            tools[#tools + 1] = name
        end
    end

    return tools
end

local function package_is_installed(name)
    local receipt = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", name, "mason-receipt.json")
    return vim.uv.fs_stat(receipt) ~= nil
end

local function install_missing_tools()
    local missing = {}
    for _, name in ipairs(configured_tools()) do
        if not package_is_installed(name) and vim.fn.executable(name) ~= 1 then
            missing[#missing + 1] = name
        end
    end

    -- Keep normal startups local and quiet. The registry is only refreshed
    -- when there is actually something to install.
    if #missing == 0 then
        return
    end

    local ok, mr = pcall(require, "mason-registry")
    if not ok then
        vim.notify("mason-registry not found", vim.log.levels.ERROR)
        return
    end

    local function notify(msg, level)
        vim.notify(msg, level or vim.log.levels.INFO)
    end

    local function enable_lsp(package_name)
        for _, entry in ipairs(lsp_entries()) do
            if mason_package_name(entry) == package_name then
                vim.lsp.enable(entry.name)
                return
            end
        end
    end

    mr.refresh(function()
        for _, package_name in ipairs(missing) do
            local has_pkg, pkg = pcall(mr.get_package, package_name)
            if has_pkg then
                notify("Installing missing tool: " .. package_name)
                pkg:install():once("install:success", function()
                    enable_lsp(package_name)
                end)
            else
                notify("Mason package not found: " .. package_name, vim.log.levels.WARN)
            end
        end
    end)
end

setup_lspconfig = function()
    for _, entry in ipairs(lsp_entries()) do
        vim.lsp.enable(entry.name)
    end
end

setup_mason_lspconfig = function()
    local exclude = {}
    for _, entry in ipairs(lsp_entries()) do
        if entry.replace then
            exclude[#exclude + 1] = entry.replace
        end
    end

    require("mason-lspconfig").setup({
        automatic_enable = { exclude = exclude },
    })
end

setup_mason = function()
    require("mason").setup({
        registries = {
            "github:mason-org/mason-registry",
            "github:Crashdummyy/mason-registry",
        },
    })

    -- A filesystem-only check is cheap; registry refresh/network work only
    -- happens when one of the configured tools is missing.
    vim.defer_fn(install_missing_tools, 100)
end

setup_lazydev = function()
    ---@diagnostic disable-next-line: missing-fields
    require("lazydev").setup({
        library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
    })

    require("blink-cmp").add_source_provider("lazydev", {
        name = "LazyDev",
        enabled = true,
        module = "lazydev.integrations.blink",
        -- make lazydev completions top priority (see `:h blink.cmp`)
        score_offset = 100,
    })

    local config = require("blink.cmp.config")

    ---@diagnostic disable-next-line: param-type-mismatch
    config.sources.default = vim.list_extend(config.sources.default, { "lazydev" })
end
