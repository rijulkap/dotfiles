vim.pack.add({{ src = "https://github.com/mason-org/mason.nvim" }}, { confirm = false })
require("mason").setup()

vim.pack.add({ { src = "https://github.com/neovim/nvim-lspconfig" } }, { confirm = false })

vim.pack.add({ { src = "https://github.com/mason-org/mason-lspconfig.nvim" } }, { confirm = false })

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

vim.pack.add({ { src = "https://github.com/folke/lazydev.nvim" } }, { confirm = false })
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
