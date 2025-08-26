local M = {}

vim.opt.laststatus = 3

-- Don't show the command that produced the quickfix list.
vim.g.qf_disable_statusline = 1

-- Show the mode in my custom component instead.
vim.o.showmode = false

--- Keeps track of the highlight groups I've already created.
---@type table<string, boolean>
local statusline_hls = {}

local icons = require("icons")

---@param hl string
---@return string
function M.get_or_create_hl(hl)
    local hl_name = "Statusline" .. hl

    if not statusline_hls[hl] then
        local bg_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
        local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
        if not bg_hl or not bg_hl.bg or not fg_hl or not fg_hl.fg then
            -- Fallback to default StatusLine fg/bg if something is missing
            local sl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
            vim.api.nvim_set_hl(0, hl_name, { bg = sl.bg, fg = sl.fg })
        else
            vim.api.nvim_set_hl(0, hl_name, { bg = ("#%06x"):format(bg_hl.bg), fg = ("#%06x"):format(fg_hl.fg) })
        end
        statusline_hls[hl] = true
    end

    return hl_name
end

---@param components string[]
---@return string
-- Returns the correct default hl for the statusline being rendered.
local function default_status_hl()
    local winid = rawget(vim.g, "statusline_winid") or 0
    local active = (winid ~= 0 and winid == vim.api.nvim_get_current_win())
    return active and "StatusLine" or "StatusLineNC"
end

--- Current mode.
---@return string
function M.mode_component()
    -- Note that: \19 = ^S and \22 = ^V.
    local mode_to_str = {
        ["n"] = "NORMAL",
        ["no"] = "OP-PENDING",
        ["nov"] = "OP-PENDING",
        ["noV"] = "OP-PENDING",
        ["no\22"] = "OP-PENDING",
        ["niI"] = "NORMAL",
        ["niR"] = "NORMAL",
        ["niV"] = "NORMAL",
        ["nt"] = "NORMAL",
        ["ntT"] = "NORMAL",
        ["v"] = "VISUAL",
        ["vs"] = "VISUAL",
        ["V"] = "VISUAL",
        ["Vs"] = "VISUAL",
        ["\22"] = "VISUAL",
        ["\22s"] = "VISUAL",
        ["s"] = "SELECT",
        ["S"] = "SELECT",
        ["\19"] = "SELECT",
        ["i"] = "INSERT",
        ["ic"] = "INSERT",
        ["ix"] = "INSERT",
        ["R"] = "REPLACE",
        ["Rc"] = "REPLACE",
        ["Rx"] = "REPLACE",
        ["Rv"] = "VIRT REPLACE",
        ["Rvc"] = "VIRT REPLACE",
        ["Rvx"] = "VIRT REPLACE",
        ["c"] = "COMMAND",
        ["cv"] = "VIM EX",
        ["ce"] = "EX",
        ["r"] = "PROMPT",
        ["rm"] = "MORE",
        ["r?"] = "CONFIRM",
        ["!"] = "SHELL",
        ["t"] = "TERMINAL",
    }

    local mode = mode_to_str[vim.api.nvim_get_mode().mode] or "UNKNOWN"

    local hl = "Other"
    if mode:find("NORMAL") then
        hl = "Normal"
    elseif mode:find("PENDING") then
        hl = "Pending"
    elseif mode:find("VISUAL") then
        hl = "Visual"
    elseif mode:find("INSERT") or mode:find("SELECT") then
        hl = "Insert"
    elseif mode:find("COMMAND") or mode:find("TERMINAL") or mode:find("EX") then
        hl = "Command"
    end

    return table.concat({
        -- string.format('%%#StatuslineModeSeparator%s#', hl),
        string.format(" %%#StatuslineMode%s#%s", hl, mode),
        -- string.format('%%#StatuslineModeSeparator%s#', hl),
    })
end

--- Git branch + optional hunks count.
function M.git_component()
    local head = vim.b.gitsigns_head
    if not head or head == "" then
        return ""
    end
    return string.format("%%#%s#%s %s%%#%s#", "Special", icons.git.Branch, head, default_status_hl())
end

--- Gitsigns diff summary (added/changed/removed).
---@return string
function M.diff_component()
    local dict = vim.b.gitsigns_status_dict
    if not dict then
        return ""
    end

    local parts = {}

    local function seg(label_hl, icon, count)
        if not count or count == 0 then
            return nil
        end
        local map = { added = "GitSignsAdd", changed = "GitSignsChange", removed = "GitSignsDelete" }
        local hl = M.get_or_create_hl(map[label_hl] or "Normal")
        return string.format("%%#%s#%s %d", hl, icon, count)
    end

    parts[#parts + 1] = seg("added", icons.git.Added, dict.added)
    parts[#parts + 1] = seg("changed", icons.git.Changed, dict.changed)
    parts[#parts + 1] = seg("removed", icons.git.Removed, dict.removed)

    return table.concat(
        vim.tbl_filter(function(x)
            return x and #x > 0
        end, parts),
        " "
    )
end

--- The current debugging status (if any).
-- ---@return string?
-- function M.dap_component()
--     if not package.loaded["dap"] or require("dap").status() == "" then
--         return nil
--     end
--     -- return string.format('%%#%s#%s  %s', M.get_or_create_hl 'Special', icons.misc.bug, require('dap').status())
--     return string.format("%%#%s#%s  %s", M.get_or_create_hl("Special"), "", require("dap").status())
-- end

---@type table<string, string?>
local progress_status = {
    client = nil,
    kind = nil,
    title = nil,
}

vim.api.nvim_create_autocmd("LspProgress", {
    group = vim.api.nvim_create_augroup("rijul/statusline", { clear = true }),
    desc = "Update LSP progress in statusline",
    pattern = { "begin", "end" },
    callback = function(args)
        if not args.data then
            return
        end
        progress_status = {
            client = vim.lsp.get_client_by_id(args.data.client_id).name,
            kind = args.data.params.value.kind,
            title = args.data.params.value.title,
        }

        if progress_status.kind == "end" then
            progress_status.title = nil
            vim.defer_fn(function()
                vim.cmd.redrawstatus()
            end, 3000)
        else
            vim.cmd.redrawstatus()
        end
    end,
})

--- The latest LSP progress message.
---@return string?
function M.lsp_progress_component()
    if not progress_status.client or not progress_status.title then
        return nil
    end
    if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
        return nil
    end

    return table.concat({
        string.format("%%#%s#%s ", M.get_or_create_hl("Error"), icons.diagnostics.Spinner),
        string.format("%%#%s#%s  ", M.get_or_create_hl("Error"), progress_status.client),
        string.format("%%#%s#%s...", M.get_or_create_hl("Error"), progress_status.title),
    })
end

--- LSP client names (when there is no progress event).
---@return string
function M.lsp_names_component()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if not clients or #clients == 0 then
        return ""
    end
    local names = {}
    for _, c in ipairs(clients) do
        names[#names + 1] = c.name
    end
    return string.format("%%#%s#%s  %s", M.get_or_create_hl("Special"), icons.misc.Cogs, table.concat(names, ", "))
end

local Sev = vim.diagnostic.severity -- bi-directional map
local DIAG_ORDER = { "ERROR", "WARN", "INFO", "HINT" }
local last_diagnostic_component = ""
--- Diagnostic counts in the current buffer.
---@return string
function M.diagnostics_component()
    if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
        return last_diagnostic_component
    end

    local counts = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }
    for _, d in ipairs(vim.diagnostic.get(0)) do
        local name = Sev[d.severity] -- 1->"ERROR"
        if name then
            counts[name] = counts[name] + 1
        end
    end

    local parts = {}
    for _, name in ipairs(DIAG_ORDER) do
        local n = counts[name]
        if n ~= 0 then
            local hl = "Diagnostic" .. name:sub(1, 1) .. name:sub(2):lower()
            parts[#parts + 1] = string.format("%%#%s#%s %d", M.get_or_create_hl(hl), icons.diagnostics[name], n)
        end
    end

    last_diagnostic_component = table.concat(parts, " ")
    return last_diagnostic_component
end

--- The buffer's filetype (with icon).
---@return string
function M.filetype_component()
    local devicons = require("nvim-web-devicons")

    local filetype = vim.bo.filetype
    if filetype == "" then
        filetype = "[No Name]"
    end

    local icon, icon_hl
    local buf_name = vim.api.nvim_buf_get_name(0)
    local name, ext = vim.fn.fnamemodify(buf_name, ":t"), vim.fn.fnamemodify(buf_name, ":e")
    icon, icon_hl = devicons.get_icon(name, ext)
    if not icon then
        icon, icon_hl = devicons.get_icon_by_filetype(filetype, { default = true })
    end
    icon_hl = M.get_or_create_hl(icon_hl or "Normal")

    return string.format("%%#%s#%s %%#StatuslineTitle#%s", icon_hl, icon, filetype)
end

--- Python venv name (only in Python buffers).
---@return string
function M.python_venv_component()
    if vim.bo.filetype ~= "python" then
        return ""
    end
    local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_DEFAULT_ENV") or os.getenv("PYENV_VERSION")
    if not venv or venv == "" then
        return ""
    end
    local name = venv
    if venv:find("/", 1, true) or venv:find("\\", 1, true) then
        name = vim.fn.fnamemodify(venv, ":t")
    end
    return string.format("%%#%s#%s %s", M.get_or_create_hl("Special"), icons.misc.Python, name)
end


function M.eol_encoding_component()
    local fmt = vim.bo.fileformat or "unix"
    local enc = (vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc):lower()
    local parts = {}
    if fmt ~= "unix" then
        parts[#parts + 1] = fmt
    end
    if enc ~= "utf-8" then
        parts[#parts + 1] = enc
    end
    if #parts == 0 then
        return ""
    end
    return string.format("%%#%s# %s", M.get_or_create_hl("Other"), table.concat(parts, " · "))
end
--- Search count (/ or ?), disappears when not searching.
-- ---@return string
-- function M.search_component()
--     local ok, sc = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 50 })
--     if not ok or not sc or sc.total == 0 then
--         return ""
--     end
--     return string.format("%%#%s# %d/%d", M.get_or_create_hl("Identifier"), sc.current or 0, sc.total or 0)
-- end

--- Shows when recording a macro with q{reg}.
-- ---@return string
-- function M.recording_component()
--     local reg = vim.fn.reg_recording()
--     if reg == "" then
--         return ""
--     end
--     return string.format("%%#%s# @%s", M.get_or_create_hl("PreProc"), reg)
-- end

--- Spell indicator.
-- ---@return string
-- function M.spell_component()
--     if not vim.wo.spell then
--         return ""
--     end
--     return string.format("%%#%s# SPELL", M.get_or_create_hl("Type"))
-- end

--- The current line, total line count, and column position.
---@return string
function M.position_component()
    local line = vim.fn.line(".")
    local line_count = vim.api.nvim_buf_line_count(0)
    local col = vim.fn.virtcol(".")

    return string.format("%%#StatuslineTitle#%d:%d", line, col)
end

--- Renders the statusline.
---@return string
function M.render()
    local function sep_component()
        return string.format("%%#%s#  |  ", default_status_hl())
    end

    local function concat_components(components)
        local items = vim.iter(components)
            :filter(function(c)
                return c and #c > 0
            end)
            :totable()
        if #items == 0 then
            return ""
        end

        local acc = items[1]
        for i = 2, #items do
            acc = acc .. sep_component() .. items[i]
        end
        return acc
    end

    -- Left: mode bubble | git | diff | python venv | dap / lsp progress
    local left = concat_components({
        M.mode_component(),
        M.git_component(),
        M.diff_component(),
        M.python_venv_component(),
        -- M.dap_component(),
    })

    -- Right: diagnostics | filetype | fileformat/encoding | search | spell | recording | position
    local right = concat_components({
        M.lsp_progress_component() or concat_components({ M.diagnostics_component(), M.lsp_names_component() }),
        M.filetype_component(),
        M.eol_encoding_component(),
        -- M.search_component(),
        -- M.spell_component(),
        M.position_component(),
    })

    return table.concat({
        left,
        "%#StatusLine#%=",
        right,
        " ",
    })
end

vim.o.statusline = "%!v:lua.require'statusline'.render()"

return M
