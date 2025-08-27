require("pluginmgr").add_plugin({
    src = "https://github.com/mason-org/mason.nvim",
    data = { config = function() setup_mason() end },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/neovim/nvim-lspconfig",
})

require("pluginmgr").add_plugin({
    src = "https://github.com/mason-org/mason-lspconfig.nvim",
    data = { event = { "BufReadPre", "BufNewFile" }, config = function() setup_mason_lspcfg() end },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/folke/lazydev.nvim",
    data = { event = { "FileType" }, pattern = "lua", config = function() setup_lazydev() end },
})

function setup_mason()
    require("mason").setup()
end

function setup_mason_lspcfg()
    local mr = require("mason-registry")
    mr.refresh(function()
        for _, tool in ipairs(vim.g.formatters) do
            local p = mr.get_package(tool)
            if not p:is_installed() then
                p:install()
            end
        end
    end)

    require("mason-lspconfig").setup({
        ensure_installed = vim.g.lsps,
        automatic_enable = true,
    })
end

function setup_lazydev()
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
