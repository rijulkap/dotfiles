return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = function(_)
            local function shorten_path(path, max_len)
                -- Normalize path separators for Windows
                path = path:gsub("\\", "/")

                local parts = {}
                for part in string.gmatch(path, "[^/]+") do
                    table.insert(parts, part)
                end

                -- Start from the filename and move up to 2 parents
                local final_parts = {}
                for i = #parts, math.max(#parts - 2, 1), -1 do
                    table.insert(final_parts, 1, parts[i])
                end

                local result = table.concat(final_parts, "/")

                -- Truncate if too long
                if #result > max_len then
                    result = "…" .. result:sub(-max_len + 1)
                end

                return result
            end

            local function custom_filename()
                local path = vim.fn.expand("%:p")
                if path == "" then
                    return ""
                end
                return shorten_path(path, 40)
            end

            local lualine_b = {
                {
                    "filetype",
                    icon_only = true,
                    padding = { left = 1, right = 0 },
                    -- separator = "",
                },
                { custom_filename },
                { "fileformat" },
            }

            if vim.bo.filetype == "python" then
                local virtual_env = function()
                    local conda_env = os.getenv("CONDA_DEFAULT_ENV")
                    local venv_path = os.getenv("VIRTUAL_ENV")

                    if venv_path == nil then
                        if conda_env == nil then
                            return ""
                        else
                            return string.format("%s (conda)", conda_env)
                        end
                    else
                        local venv_name = vim.fn.fnamemodify(venv_path, ":t")
                        return string.format("%s (venv)", venv_name)
                    end
                end

                table.insert(lualine_b, virtual_env)
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
                        tabline = 2000,
                        winbar = 2000,
                    },
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            fmt = function(str)
                                return str:sub(1, 1)
                            end,
                        },
                    },
                    lualine_b = lualine_b,
                    lualine_c = {
                        { "branch" },
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
            }
        end,
    },
}
