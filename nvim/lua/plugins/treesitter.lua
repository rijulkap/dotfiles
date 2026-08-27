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
        build = ":TSUpdate",
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
    vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function(event)
            local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
            local parser = lang and vim.treesitter.get_parser(event.buf, lang)

            -- Leave the filetype's standard indentexpr in place when the
            -- parser is missing or has no Tree-sitter indentation queries.
            if not parser then
                return
            end

            pcall(vim.treesitter.start, event.buf, lang)
            -- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            local query_ok, indent_query = pcall(vim.treesitter.query.get, lang, "indents")
            if query_ok and indent_query then
                vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end,
    })
end
