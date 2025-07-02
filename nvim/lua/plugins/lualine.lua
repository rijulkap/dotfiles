return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = function(_)
            local function python_venv()
                if vim.bo.filetype == "python" then
                    local venv_path = os.getenv("VIRTUAL_ENV")

                    if venv_path == nil then
                        return ""
                    else
                        local venv_name = vim.fn.fnamemodify(venv_path, ":t")
                        return string.format("%s (venv)", venv_name)
                    end
                else
                    return ""
                end
            end

            local function git_branch()
                local head = vim.b.gitsigns_head
                if not head or head == "" then
                    return ""
                end

                return string.format(" %s", head)
            end

            return {
                options = {
                    icons_enabled = true,
                    theme = "auto",
                    -- component_separators = { left = "|", right = "|" },
                    section_separators = { left = "", right = "" },
                    -- section_separators = { left = '', right = '' },
                    disabled_filetypes = {
                        statusline = { "snacks_dashboard" },
                    },
                    ignore_focus = {},
                    always_divide_middle = false,
                    always_show_tabline = false,
                    globalstatus = true,
                    refresh = {
                        statusline = 100,
                        tabline = 10000,
                        winbar = 10000,
                    },
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            -- fmt = function(str)
                            --     return str:sub(1, 1)
                            -- end,
                        },
                    },
                    lualine_b = {
                        { "fileformat" },
                        { git_branch },
                        { python_venv },
                        {
                            "filetype",
                            icon_only = true,
                            padding = { left = 1, right = 0 },
                            separator = "",
                        },
                        { "filename", padding = { left = 0, right = 1 } },
                    },
                    lualine_c = {
                        {
                            "diff",
                            symbols = {
                                added = " ",
                                modified = " ",
                                removed = " ",
                            },
                            source = function()
                                local gitsigns = vim.b.gitsigns_status_dict
                                if gitsigns then
                                    return {
                                        added = gitsigns.added,
                                        modified = gitsigns.changed,
                                        removed = gitsigns.removed,
                                    }
                                end
                            end,
                        },
                    },
                    lualine_x = {
                        {
                            "diagnostics",
                            symbols = {
                                error = " ",
                                warn = " ",
                                info = " ",
                                hint = " ",
                            },
                        },
                    },
                    lualine_y = {
                        {
                            "lsp_status",
                        },
                        {
                            function()
                                return "  " .. require("dap").status()
                            end,
                            cond = function()
                                return package.loaded["dap"] and require("dap").status() ~= ""
                            end,
                        },
                    },
                    lualine_z = { { "location" } },
                },
                extensions = { "quickfix" },
            }
        end,
    },
}
