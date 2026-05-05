local setup_mason
local setup_mason_lspcfg
local setup_lazydev

require("pluginmgr").add_plugin({
    src = "https://github.com/mason-org/mason.nvim",
    data = {
        config = function()
            setup_mason()
        end,
    },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/neovim/nvim-lspconfig",
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

local function install_missing_lsp()
    local ok, mr = pcall(require, "mason-registry")
    if not ok then
        vim.notify("mason-registry not found", vim.log.levels.ERROR)
        return
    end

    local function notify(msg, level)
        vim.notify(msg, level or vim.log.levels.INFO)
    end

    local function enable_lsp(pkg)
        local lsp_name = pkg.spec.neovim and pkg.spec.neovim.lspconfig

        if not lsp_name then
            notify("LSP " .. pkg.name .. " does not have a neovim config, skipping", vim.log.levels.WARN)
            return
        end

        vim.lsp.enable(lsp_name)
    end

    mr.refresh(function()
        local installed = {}
        for _, name in ipairs(mr.get_installed_package_names()) do
            installed[name] = true
        end

        local seen = {}

        for lsp_name, mason_packages in pairs(vim.g.lsps or {}) do
            if mason_packages == true then
                mason_packages = { lsp_name }
            end

            for _, package_name in ipairs(mason_packages) do
                if not seen[package_name] then
                    seen[package_name] = true

                    local has_pkg, pkg = pcall(mr.get_package, package_name)
                    if not has_pkg then
                        notify("Mason package not found: " .. package_name, vim.log.levels.WARN)
                    elseif installed[package_name] or vim.fn.executable(package_name) == 1 then
                        enable_lsp(pkg)
                    else
                        notify("Installing missing lsp: " .. package_name)

                        pkg:install():once("install:success", function()
                            enable_lsp(pkg)
                        end)
                    end
                end
            end
        end

        for _, tool in ipairs(vim.g.formatters or {}) do
            if not seen[tool] then
                seen[tool] = true

                local has_pkg, pkg = pcall(mr.get_package, tool)
                if has_pkg and not pkg:is_installed() then
                    pkg:install()
                elseif not has_pkg then
                    notify("Mason tool not found: " .. tool, vim.log.levels.WARN)
                end
            end
        end
    end)
end

setup_mason = function()
    require("mason").setup()
    install_missing_lsp()
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
