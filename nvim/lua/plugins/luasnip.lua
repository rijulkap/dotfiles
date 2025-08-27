require("pluginmgr").add_plugin({
    src = "https://github.com/rafamadriz/friendly-snippets",
})

require("pluginmgr").add_plugin({
    src = "https://github.com/L3MON4D3/LuaSnip",
    version = vim.version.range("^2"),
    data = {
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            setup_luasnip()
        end,
    },
})

function setup_luasnip()
    require("luasnip.loaders.from_vscode").lazy_load()

    local ls = require("luasnip")
    ls.filetype_extend("lua", { "luadoc" })
    ls.filetype_extend("cs", { "csharpdoc" })

    local function unlink()
        if ls.expand_or_jumpable() then
            ls.unlink_current()
        end
    end

    require("utils").dyn_exit:add(unlink)

    local types = require("luasnip.util.types")

    require("luasnip").setup({
        -- region_check_events = "CursorMoved",
        -- Check if the current snippet was deleted.
        -- delete_check_events = "TextChanged",
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
    })
end
