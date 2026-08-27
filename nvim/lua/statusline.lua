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
local devicons = require("nvim-web-devicons")

-- Note that: \19 = ^S and \22 = ^V.
local MODE_TO_STR = {
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

local DIFF_HLS = {
    added = "GitSignsAdd",
    changed = "GitSignsChange",
    removed = "GitSignsDelete",
}

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
    local mode = MODE_TO_STR[vim.api.nvim_get_mode().mode] or "UNKNOWN"

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

    return string.format(" %%#StatuslineMode%s#%s", hl, mode)
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
        local hl = M.get_or_create_hl(DIFF_HLS[label_hl] or "Normal")
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

local diag_aug = vim.api.nvim_create_augroup("rijul/statusline_diagnostics", { clear = true })
local lsp_names_cache = {}
local filetype_cache = {}

local function recompute_lsp_names(bufnr)
    local attached = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        attached[client.name] = true
    end
    local names = vim.tbl_keys(attached)
    table.sort(names)

    lsp_names_cache[bufnr] = #names > 0
            and string.format(
                "%%#%s#%s  %s",
                M.get_or_create_hl("Special"),
                icons.misc.Cogs,
                table.concat(names, ", ")
            )
        or ""
end

local function recompute_filetype(bufnr)
    local filetype = vim.bo[bufnr].filetype
    if filetype == "" then
        filetype = "[No Name]"
    end

    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    local name = vim.fn.fnamemodify(buf_name, ":t")
    local ext = vim.fn.fnamemodify(buf_name, ":e")
    local icon, icon_hl = devicons.get_icon(name, ext)
    if not icon then
        icon, icon_hl = devicons.get_icon_by_filetype(filetype, { default = true })
    end

    filetype_cache[bufnr] =
        string.format("%%#%s#%s %%#StatuslineTitle#%s", M.get_or_create_hl(icon_hl or "Normal"), icon, filetype)
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = diag_aug,
    callback = function(args)
        recompute_lsp_names(args.buf)
        vim.schedule(vim.cmd.redrawstatus)
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    group = diag_aug,
    callback = function(args)
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
                recompute_lsp_names(args.buf)
                vim.cmd.redrawstatus()
            end
        end)
    end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "FileType" }, {
    group = diag_aug,
    callback = function(args)
        recompute_filetype(args.buf)
    end,
})

local function truncate_middle(text, max_width)
    text = tostring(text or ""):gsub("[\r\n]+", " "):gsub("%s+", " ")
    if vim.fn.strdisplaywidth(text) <= max_width then
        return text
    end

    local keep = max_width - 1
    local head = math.floor(keep * 0.4)
    local tail = keep - head
    local chars = vim.fn.strchars(text)
    return vim.fn.strcharpart(text, 0, head) .. "…" .. vim.fn.strcharpart(text, chars - tail, tail)
end

vim.api.nvim_create_autocmd("LspProgress", {
    group = diag_aug,
    desc = "Show LSP progress outside the statusline",
    callback = function(args)
        local data = args.data
        local params = data and data.params
        local value = params and params.value
        if not data or not data.client_id or not value then
            return
        end

        local client = vim.lsp.get_client_by_id(data.client_id)
        if not client then
            return
        end

        local ok, snacks = pcall(require, "snacks")
        if not ok then
            return
        end

        local id = ("lsp-progress:%d:%s"):format(data.client_id, tostring(params.token))
        if value.kind == "end" then
            snacks.notifier.hide(id)
            return
        end

        local max_width = math.max(30, math.min(80, math.floor(vim.o.columns * 0.35)))
        local title = truncate_middle(client.name .. " · " .. (value.title or "Working"), max_width)
        local message = value.message
        if not message or message == "" then
            message = value.title or "Working"
        end
        if value.percentage then
            message = ("%d%% · %s"):format(value.percentage, message)
        end

        snacks.notifier(truncate_middle(message, max_width), vim.log.levels.INFO, {
            id = id,
            title = title,
            icon = icons.diagnostics.Spinner,
            timeout = false,
            style = "compact",
            history = false,
        })
    end,
})

--- LSP clients attached to the current buffer.
---@return string
function M.lsp_names_component()
    local bufnr = vim.api.nvim_get_current_buf()
    if lsp_names_cache[bufnr] == nil then
        recompute_lsp_names(bufnr)
    end
    return lsp_names_cache[bufnr]
end

local Sev = vim.diagnostic.severity
local DIAG_ORDER = { "ERROR", "WARN", "INFO", "HINT" }

-- Per-buffer cache: { [bufnr] = { counts=?, str=? } }
local diag_cache = {}
local last_diagnostic_component = "" -- keeps the last rendered value for insert-mode freeze

local function render_diag_str(counts)
    local parts = {}
    for _, name in ipairs(DIAG_ORDER) do
        local n = counts[name] or 0
        if n ~= 0 then
            local hl = "Diagnostic" .. name:sub(1, 1) .. name:sub(2):lower()
            local icon = (icons and icons.diagnostics and icons.diagnostics[name]) or ""
            parts[#parts + 1] = string.format("%%#%s#%s %d", M.get_or_create_hl(hl), icon, n)
        end
    end
    return table.concat(parts, " ")
end

local function recompute_diags(bufnr)
    bufnr = bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()
    local counts = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }
    for _, d in ipairs(vim.diagnostic.get(bufnr)) do
        local name = Sev[d.severity] -- 1->"ERROR"
        if name then
            counts[name] = counts[name] + 1
        end
    end
    local str = render_diag_str(counts)
    diag_cache[bufnr] = { counts = counts, str = str }
    -- If this is the current buffer and we're not in insert, update the “last” string and refresh.
    if bufnr == vim.api.nvim_get_current_buf() and not vim.startswith(vim.api.nvim_get_mode().mode, "i") then
        last_diagnostic_component = str
        vim.schedule(vim.cmd.redrawstatus)
    end
end

-- Keep cache fresh.
vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufEnter" }, {
    group = diag_aug,
    callback = function(args)
        -- args.buf is set for DiagnosticChanged/BufEnter
        recompute_diags(args.buf or 0)
    end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = diag_aug,
    callback = function(args)
        diag_cache[args.buf] = nil
        lsp_names_cache[args.buf] = nil
        filetype_cache[args.buf] = nil
    end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = diag_aug,
    callback = function()
        statusline_hls = {}
        filetype_cache = {}
        vim.cmd.redrawstatus()
    end,
})

--- Diagnostic counts in the current buffer (reads from cache).
---@return string
function M.diagnostics_component()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Seed cache if missing (first render, or after buffer was wiped).
    if not (diag_cache[bufnr] and diag_cache[bufnr].str) then
        recompute_diags(bufnr)
    end

    -- Freeze during insert mode: show last known rendered string.
    if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
        return last_diagnostic_component
    end

    local s = (diag_cache[bufnr] and diag_cache[bufnr].str) or ""
    last_diagnostic_component = s
    return s
end

--- The buffer's filetype (with icon).
---@return string
function M.filetype_component()
    local bufnr = vim.api.nvim_get_current_buf()
    if filetype_cache[bufnr] == nil then
        recompute_filetype(bufnr)
    end
    return filetype_cache[bufnr]
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
    -- 5-wide line number, 3-wide column (zero-padded col as example)
    local s = "%#StatuslineTitle#%5l:%03c"
    return s .. string.format("%%#%s#", default_status_hl())
end

local function sep_component()
    return string.format("%%#%s#  |  ", default_status_hl())
end

local function concat_components(components)
    local items = {}
    for _, component in ipairs(components) do
        if component and #component > 0 then
            items[#items + 1] = component
        end
    end
    return table.concat(items, sep_component())
end

--- Renders the statusline.
---@return string
function M.render()
    if vim.o.columns >= 100 then
        local left = concat_components({
            M.mode_component(),
            M.git_component(),
            M.diff_component(),
            M.python_venv_component(),
        })
        local right = concat_components({
            M.diagnostics_component(),
            M.lsp_names_component(),
            M.filetype_component(),
            M.eol_encoding_component(),
            M.position_component(),
        })
        return table.concat({
            left,
            "%#StatusLine#%=",
            right,
            " ",
        })
    else
        local left = concat_components({
            M.mode_component(),
            M.diff_component(),
        })
        local right = concat_components({
            M.diagnostics_component(),
            M.position_component(),
        })
        return table.concat({
            left,
            "%#StatusLine#%=",
            right,
            " ",
        })
    end
end

vim.o.statusline = "%!v:lua.require'statusline'.render()"

return M
