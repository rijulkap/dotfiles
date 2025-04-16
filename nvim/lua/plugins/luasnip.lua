return {
    "L3MON4D3/LuaSnip",
    event = { "BufReadPre", "BufNewFile" },
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    build = "make install_jsregexp",
    dependencies = {
        {
            "rafamadriz/friendly-snippets",
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end,
        },
    },
    opts = function()
        local ls = require("luasnip")
        ls.filetype_extend("lua", { "luadoc" })
        ls.filetype_extend("cs", { "csharpdoc" })

        vim.keymap.set({ "i", "n", "s" }, "<esc><esc>", function()
            if ls.expand_or_jumpable() then
                ls.unlink_current()
            end
        end, { desc = "Close Snippet engine" })

        local types = require("luasnip.util.types")
        return {
            -- Check if the current snippet was deleted.
            delete_check_events = "TextChanged",
            -- Display a cursor-like placeholder in unvisited nodes
            -- of the snippet.
            ext_opts = {
                [types.insertNode] = {
                    unvisited = {
                        virt_text = { { "|", "Conceal" } },
                        virt_text_pos = "inline",
                    },
                },
                [types.exitNode] = {
                    unvisited = {
                        virt_text = { { "|", "Conceal" } },
                        virt_text_pos = "inline",
                    },
                },
                [types.choiceNode] = {
                    active = {
                        virt_text = { { "(snippet) choice node", "LspInlayHint" } },
                    },
                },
            },
        }
    end,
}
