require("pluginmgr").add_plugin({
    src = "https://github.com/Saghen/blink.cmp",
    version = vim.version.range("^1"),
    data = { event = { "BufReadPre", "BufNewFile" }, config = function() setup_blink() end },
})

function setup_blink()
    require("blink-cmp").setup({
        -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- adjusts spacing to ensure icons are aligned
        completion = {
            menu = {
                winblend = vim.o.pumblend,
                draw = {
                    columns = {
                        { "label", "label_description", gap = 1 },
                        { "kind_icon", "kind" },
                    },
                },
            },
            accept = {
                auto_brackets = {
                    enabled = true,
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
            },
            list = {
                selection = { preselect = false, auto_insert = false },
            },
            trigger = { show_in_snippet = true },
            ghost_text = { enabled = true },
        },
        keymap = {
            ["<esc>"] = {
                function(cmp)
                    -- Check if snippet is active
                    if require("luasnip").expand_or_jumpable() then
                        if cmp.is_menu_visible() then -- If menu is shown, close it
                            cmp.hide()
                            return true -- return true to skip fallback (and hence not leave snippet)
                        end
                    end
                end,
                "fallback",
            },
            ["<C-e>"] = { "hide", "fallback" },

            ["<C-n>"] = { "select_next", "show" },
            ["<C-p>"] = { "select_prev" },

            ["<CR>"] = { "accept", "fallback" },

            ["<Tab>"] = {
                function(cmp)
                    if cmp.snippet_active() then
                        return cmp.accept()
                    else
                        return cmp.select_and_accept()
                    end
                end,
                "snippet_forward",
                "fallback",
            },
            ["<S-Tab>"] = { "snippet_backward", "fallback" },

            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        },
        appearance = {
            nerd_font_variant = "normal",
            kind_icons = {
                Array = " ",
                Boolean = "󰨙 ",
                Class = " ",
                Codeium = "󰘦 ",
                Color = " ",
                Control = " ",
                Collapsed = " ",
                Constant = "󰏿 ",
                Constructor = " ",
                Copilot = " ",
                Enum = " ",
                EnumMember = " ",
                Event = " ",
                Field = " ",
                File = " ",
                Folder = " ",
                Function = "󰊕 ",
                Interface = " ",
                Key = " ",
                Keyword = " ",
                Method = "󰊕 ",
                Module = " ",
                Namespace = "󰦮 ",
                Null = " ",
                Number = "󰎠 ",
                Object = " ",
                Operator = " ",
                Package = " ",
                Property = " ",
                Reference = " ",
                Snippet = " ",
                String = " ",
                Struct = "󰆼 ",
                TabNine = "󰏚 ",
                Text = " ",
                TypeParameter = " ",
                Unit = " ",
                Value = " ",
                Variable = "󰀫 ",
            },
        },
        cmdline = { enabled = false },

        sources = {
            -- add lazydev to your completion providers
            default = { "lsp", "path", "snippets", "buffer" },
        },
        -- experimental auto-brackets support
        -- accept = { auto_brackets = { enabled = true } }

        signature = { enabled = true },
        snippets = { preset = "luasnip" },
    })
end
