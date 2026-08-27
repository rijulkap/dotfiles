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
    local function use_syntax_fallback(bufnr)
        pcall(vim.treesitter.stop, bufnr)

        local filetype = vim.bo[bufnr].filetype
        if filetype ~= "" then
            vim.bo[bufnr].syntax = filetype
        end
    end

    local function has_compatible_highlights(bufnr, lang)
        local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
        if not parser_ok or not parser then
            return false
        end

        local function highlights_are_valid(tree_lang)
            local query_ok, highlight_query = pcall(vim.treesitter.query.get, tree_lang, "highlights")
            return query_ok and highlight_query ~= nil
        end

        if not highlights_are_valid(lang) then
            return false
        end

        -- Parsing discovers injected languages, such as Vimscript inside a
        -- Lua `vim.cmd()` string. Their highlight queries must match their own
        -- parsers as well or the highlighter will fail on its first redraw.
        local compatible = true
        local parse_ok = pcall(function()
            parser:parse(true)
            parser:for_each_tree(function(_, language_tree)
                if compatible and not highlights_are_valid(language_tree:lang()) then
                    compatible = false
                end
            end)
        end)

        return parse_ok and compatible
    end

    -- Some built-in ftplugins start Tree-sitter before our FileType callback.
    -- Guard that entry point as well so an incompatible query never reaches
    -- the decoration provider.
    local treesitter_start = vim.treesitter.start
    vim.treesitter.start = function(bufnr, lang)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        lang = lang or vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)

        if not lang or not has_compatible_highlights(bufnr, lang) then
            use_syntax_fallback(bufnr)
            return
        end

        return treesitter_start(bufnr, lang)
    end

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
            if not lang then
                use_syntax_fallback(event.buf)
                return
            end

            -- A parser can load successfully while still being too old for
            -- the installed queries. Validate highlights before registering
            -- the decoration provider, where the error would be deferred.
            if not has_compatible_highlights(event.buf, lang) then
                use_syntax_fallback(event.buf)
                return
            end

            local start_ok = pcall(vim.treesitter.start, event.buf, lang)
            if not start_ok then
                use_syntax_fallback(event.buf)
                return
            end

            -- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            local query_ok, indent_query = pcall(vim.treesitter.query.get, lang, "indents")
            if query_ok and indent_query then
                vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end,
    })
end
