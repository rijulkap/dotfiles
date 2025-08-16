local setup_mason
local setup_mason_lspcfg
local setup_lazydev

require("pluginmgr").add_normal_spec({ src = "https://github.com/mason-org/mason.nvim" })
require("pluginmgr").add_normal_spec({ src = "https://github.com/neovim/nvim-lspconfig" })
require("pluginmgr").add_lazy_spec({ src = "https://github.com/mason-org/mason-lspconfig.nvim" })
require("pluginmgr").add_normal_spec({ src = "https://github.com/folke/lazydev.nvim" })

require("pluginmgr").add_normal_setup(function()
    setup_mason()
end)
require("pluginmgr").pack_setup_on_event({ "BufReadPre", "BufNewFile" }, "mason-lspconfig.nvim", function()
    setup_mason_lspcfg()
end)
require("pluginmgr").add_normal_setup(function()
    setup_lazydev()
end)

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
    require("lazydev").setup({
        library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
        sources = {
            -- add lazydev to your completion providers
            default = { "lazydev" },
            providers = {
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    score_offset = 100, -- show at a higher priority than lsp
                },
            },
        },
    })
end
