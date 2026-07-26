local setup_ts_context
local setup_ts

local languages = {
    bash = { "bash", "sh" },
    c = { "c" },
    cpp = { "cpp" },
    c_sharp = { "cs" },
    html = { "html" },
    javascript = { "javascript", "javascriptreact" },
    json = { "json" },
    lua = { "lua" },
    luadoc = {},
    markdown = { "markdown" },
    python = { "python" },
    rust = { "rust" },
    tsx = { "typescriptreact" },
    typescript = { "typescript" },
    vim = { "vim" },
    vimdoc = {},
}

local parsers = vim.tbl_keys(languages)
table.sort(parsers)

local filetypes = {}
for _, parser in ipairs(parsers) do
    vim.list_extend(filetypes, languages[parser])
end

require("pluginmgr").add_plugin({
    src = "https://github.com/nvim-treesitter/nvim-treesitter-context",
    data = {
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            setup_ts_context()
        end,
    },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
    data = {
        config = function()
            setup_ts()
        end,
    },
})

setup_ts_context = function()
    require("treesitter-context").setup()
    vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true })
end

setup_ts = function()
    -- Check/install parsers after the dashboard has rendered, rather than
    -- blocking initial UI setup or waiting for the first real buffer.
    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
            vim.defer_fn(function()
                require("nvim-treesitter").install(parsers)
            end, 100)
        end,
    })
    vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(ev)
            local name, kind = ev.data.spec.name, ev.data.kind
            if name == "nvim-treesitter" and kind == "update" then
                if not ev.data.active then
                    vim.cmd.packadd("nvim-treesitter")
                end
                vim.cmd("TSUpdate")
            end
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function()
            vim.treesitter.start()
            -- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end
