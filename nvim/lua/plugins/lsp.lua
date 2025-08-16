local function setup_mason()
    require("mason").setup()
end

require("pluginmgr").add_normal({ src = "https://github.com/mason-org/mason.nvim" }, setup_mason)

require("pluginmgr").add_normal({ src = "https://github.com/neovim/nvim-lspconfig" }, nil)

local function setup_mason_lspcfg()
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
require("pluginmgr").add_lazy({ src = "https://github.com/mason-org/mason-lspconfig.nvim" })

require("pluginmgr").pack_setup_on_event({ "BufReadPre", "BufNewFile" }, "mason-lspconfig.nvim", setup_mason_lspcfg)

local function setup_lazydev()
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

require("pluginmgr").add_normal({ src = "https://github.com/folke/lazydev.nvim" })

