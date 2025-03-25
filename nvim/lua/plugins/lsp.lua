return {
    { -- LSP Configuration & Plugins
        "neovim/nvim-lspconfig",
        dependencies = {
            "saghen/blink.cmp",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        event = { "BufReadPre", "BufNewFile" },

        config = function()
            local servers = {
                clangd = {
                    cmd = {
                        "/home/rk-dev/.espressif/tools/esp-clang/16.0.1-fe4f10a809/esp-clang/bin/clangd",
                        "--background-index",
                        "--query-driver=**",
                    },
                },
                tinymist = {
                    filetypes = { "typst" },
                },
                basedpyright = {
                    settings = {
                        basedpyright = {
                            disableOrganizeImports = true,
                            typeCheckingMode = "standard",
                            analysis = {
                                ignore = { "*" },
                            },
                        },
                    },
                },
                ruff = {},
                jsonls = {
                    -- lazy-load schemastore when needed
                    on_new_config = function(new_config)
                        new_config.settings.json.schemas = new_config.settings.json.schemas or {}
                        vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
                    end,
                    settings = {
                        json = {
                            format = {
                                enable = true,
                            },
                            validate = { enable = true },
                        },
                    },
                },
                rust_analyzer = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                },
            }

            require("mason").setup()

            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                "stylua", -- Used to format Lua code
            })
            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

            require("mason-lspconfig").setup({
                ensure_installed = {},
                automatic_installation = false,
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}

                        server.capabilities = require("blink.cmp").get_lsp_capabilities(server.capabilities, true)

                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            })

            local function setup_document_highlight(bufnr)
                local highlight_augroup = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })

                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    group = highlight_augroup,
                    buffer = bufnr,
                    callback = vim.lsp.buf.document_highlight,
                })

                vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                    group = highlight_augroup,
                    buffer = bufnr,
                    callback = vim.lsp.buf.clear_references,
                })

                vim.api.nvim_create_autocmd("LspDetach", {
                    group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                    callback = function(event2)
                        vim.lsp.buf.clear_references()
                        vim.api.nvim_clear_autocmds({ group = "LspDocumentHighlight", buffer = event2.buf })
                    end,
                })
            end

            local function setup_codelens(bufnr)
                vim.lsp.codelens.refresh()
                vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                    buffer = bufnr,
                    callback = vim.lsp.codelens.refresh,
                })
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    local Snacks = require("snacks")

                    map("gd", function()
                        Snacks.picker.lsp_definitions()
                    end, "[G]oto [D]efinition")
                    map("gr", function()
                        Snacks.picker.lsp_references()
                    end, "[G]oto [R]eferences")
                    map("gI", function()
                        Snacks.picker.lsp_implementations()
                    end, "[G]oto [I]mplementation")
                    map("<leader>ll", vim.diagnostic.setloclist, "Open diagnostic [l]sp [l]oclist list")
                    map("<leader>lq", vim.diagnostic.setqflist, "Open diagnostic [l]sp [q]uickfix list")
                    map("<leader>lr", vim.lsp.buf.rename, "[l]sp [R]ename")
                    map("<leader>lc", vim.lsp.buf.code_action, "[l]sp [C]ode Action")
                    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client then
                        if
                            client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
                        then
                            setup_document_highlight(event.buf)
                        end
                        if client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens, event.buf) then
                            setup_codelens(event.buf)
                        end
                        if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                            vim.lsp.inlay_hint.enable(true)
                        end
                        if client.name == "ruff" then
                            client.server_capabilities.hoverProvider = false
                        end
                    end
                end,
            })

            vim.lsp.set_log_level("off")

            local hover = vim.lsp.buf.hover
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.lsp.buf.hover = function()
                return hover({
                    border = "rounded",
                    max_height = math.floor(vim.o.lines * 0.5),
                    max_width = math.floor(vim.o.columns * 0.4),
                })
            end

            local signature_help = vim.lsp.buf.signature_help
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.lsp.buf.signature_help = function()
                return signature_help({
                    border = "rounded",
                    max_height = math.floor(vim.o.lines * 0.5),
                    max_width = math.floor(vim.o.columns * 0.4),
                })
            end

            -- wrappers to allow for toggling
            local def_virtual_text = {
                isTrue = {
                    source = "if_many",
                    spacing = 4,
                    prefix = " ● ",
                },
                isFalse = false,
            }

            local function truncate_message(message, max_length)
                if #message > max_length then
                    return message:sub(1, max_length) .. "..."
                end
                return message
            end

            local def_virtual_lines = {
                isTrue = {
                    format = function(diagnostic)
                        local max_length = 100 -- Set your preferred max length
                        return " ● " .. truncate_message(diagnostic.message, max_length)
                    end,
                },
                isFalse = false,
            }

            local default_diagnostic_config = {
                update_in_insert = false,
                virtual_lines = def_virtual_lines.isTrue,
                virtual_text = def_virtual_text.isFalse,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.INFO] = " ",
                        [vim.diagnostic.severity.HINT] = " ",
                    },
                },
            }

            vim.diagnostic.config(default_diagnostic_config)

            -- Set Toggles
            Snacks.toggle
                .new({
                    id = "Virtual diagnostics (Lines)",
                    name = "Virtual diagnostics (Lines)",
                    get = function()
                        if vim.diagnostic.config().virtual_lines then
                            return true
                        else
                            return false
                        end
                    end,
                    set = function(state)
                        if state == true then
                            vim.diagnostic.config({ virtual_lines = def_virtual_lines.isTrue })
                        else
                            vim.diagnostic.config({ virtual_lines = def_virtual_lines.isFalse })
                        end
                    end,
                })
                :map("<leader>uvl")

            Snacks.toggle
                .new({
                    id = "Virtual diagnostics (Text)",
                    name = "Virtual diagnostics (Text)",
                    get = function()
                        if vim.diagnostic.config().virtual_text then
                            return true
                        else
                            return false
                        end
                    end,
                    set = function(state)
                        if state == true then
                            vim.diagnostic.config({ virtual_text = def_virtual_text.isTrue })
                        else
                            vim.diagnostic.config({ virtual_text = def_virtual_text.isFalse })
                        end
                    end,
                })
                :map("<leader>uvt")
        end,
    },
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    { -- optional blink completion source for require statements and module annotations
        "saghen/blink.cmp",
        opts = {
            sources = {
                -- add lazydev to your completion providers
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
                    },
                },
            },
        },
    },
}
