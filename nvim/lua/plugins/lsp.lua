local setup_mason
local setup_lspconfig
local setup_lazydev

local package_to_lsp = {
    basedpyright = "basedpyright",
    clangd = "clangd",
    ["json-lsp"] = "jsonls",
    ["lua-language-server"] = "lua_ls",
    roslyn = "roslyn",
    ruff = "ruff",
    ["rust-analyzer"] = "rust_analyzer",
    tinymist = "tinymist",
    ["typescript-language-server"] = "ts_ls",
}

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

    for _, names in ipairs({ vim.g.lsps or {}, vim.g.formatters or {} }) do
        for _, name in ipairs(names) do
            if not seen[name] then
                seen[name] = true
                tools[#tools + 1] = name
            end
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
        local lsp_name = package_to_lsp[package_name]
        if not lsp_name then
            return
        end

        vim.lsp.enable(lsp_name)
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
    for _, package_name in ipairs(vim.g.lsps or {}) do
        local lsp_name = package_to_lsp[package_name]
        if lsp_name then
            vim.lsp.enable(lsp_name)
        end
    end
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
