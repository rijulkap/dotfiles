return {
    {
        "saghen/blink.cmp",
        -- lazy = false, -- lazy loading handled internally
        event = { "BufReadPre", "BufNewFile" },
        -- optional: provides snippets for the snippet source
        version = "1.*",
        dependencies = { "L3MON4D3/LuaSnip" },
        -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        -- On musl libc based systems you need to add this flag
        -- build = 'RUSTFLAGS="-C target-feature=-crt-static" cargo build --release',
        opts = {
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
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },
                list = {
                    selection = { preselect = false, auto_insert = false },
                },
                trigger = { show_in_snippet = false },
                ghost_text = { enabled = true },
            },
            keymap = {
                ["<C-e>"] = { "hide", "fallback" },

                ["<C-n>"] = { "select_next", "show" },
                ["<C-p>"] = { "select_prev" },

                ["<Tab>"] = { "accept", "snippet_forward", "fallback" },
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
                -- Remove 'buffer' if you don't want text completions, by default it's only enabled when LSP returns no items
                default = { "lsp", "path", "snippets", "buffer" },
            },
            -- experimental auto-brackets support
            -- accept = { auto_brackets = { enabled = true } }

            signature = { enabled = true },
            snippets = { preset = "luasnip" },
        },
    },
}
