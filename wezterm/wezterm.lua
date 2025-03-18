local wezterm = require("wezterm")
local act = wezterm.action

local config = {}
-- Use config builder object if possible
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- Settings
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    config.default_prog = { "pwsh.exe", "-NoLogo", "-ExecutionPolicy", "RemoteSigned" }
    -- config.default_prog = { "powershell.exe" }
end

config.color_scheme = "Catppuccin Macchiato"
local scheme = wezterm.get_builtin_color_schemes()["Catppuccin Macchiato"]

config.font = wezterm.font_with_fallback({
    { family = "JetBrainsMono Nerd Font", scale = 1.0, weight = "Medium" },
})

config.window_background_opacity = 0.95
-- config.window_decorations = "RESIZE"
-- config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "main"

config.max_fps = 240

-- Keys
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    -- System Keys
    { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
    { key = "c", mods = "LEADER", action = act.ActivateCopyMode },
    { key = "phys:Space", mods = "LEADER", action = act.ActivateCommandPalette },
    { key = "Q", mods = "LEADER", action = act.QuitApplication },
    { key = "Enter", mods = "LEADER", action = act.ToggleFullScreen },

    --Panes
    { key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
    { key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    { key = "o", mods = "LEADER", action = act.RotatePanes("Clockwise") },
    { key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },

    -- Tabs
    { key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
    { key = "n", mods = "LEADER", action = act.ShowTabNavigator },
    { key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },
}

for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = act.ActivateTab(i - 1),
    })
end

config.key_tables = {
    resize_pane = {
        { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
        { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
        { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
        { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
        { key = "Escape", action = "PopKeyTable" },
    },
    move_tab = {
        { key = "h", action = act.MoveTabRelative(-1) },
        { key = "l", action = act.MoveTabRelative(1) },
        { key = "Escape", action = "PopKeyTable" },
    },
}

-- Tab bar configuration
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle
local SLASH = wezterm.nerdfonts.fae_slash

-- Disable dynamic tab naming by not setting foreground process as tab name
wezterm.on("format-tab-title", function(tab, _, _, _, _, _)
    local background = ""
    local foreground = ""
    if tab.is_active then
        background = scheme.tab_bar.active_tab.bg_color
        foreground = scheme.tab_bar.active_tab.fg_color
    else
        background = scheme.tab_bar.inactive_tab.bg_color
        foreground = scheme.tab_bar.inactive_tab.fg_color
    end

    local edge_background = scheme.tab_bar.background
    local edge_foreground = background

    return {
        { Background = { Color = scheme.tab_bar.background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        {
            Text = string.format(" Tab %d ", tab.tab_id + 1),
        },
        { Background = { Color = edge_foreground } },
        { Foreground = { Color = "#909090" } },
        { Text = SLASH },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_RIGHT_ARROW },
    }
end)

wezterm.on("format-window-title", function(tab, _, _, _, _)
    -- Use a static title or base it on the tab index
    return string.format(" Tab %d ", tab.tab_id + 1)
end)

-- local basename = function(s)
--     -- Nothing a little regex can't fix
--     return string.gsub(s, "(.*[/\\])(.*)", "%2")
-- end

local reduce_filepath = function(filepath)
    -- Split the file path into its components
    local parts = {}
    for part in string.gmatch(filepath, "[^/\\]+") do
        table.insert(parts, part)
    end

    -- Check if the path has more than 3 parts (2 parents + 1 file/folder)
    if #parts > 3 then
        -- Keep only the last 3 parts and add double dots before the outermost folder
        parts = { "..", parts[#parts - 2], parts[#parts - 1], parts[#parts] }
    end

    -- Reconstruct the reduced file path
    return table.concat(parts, "/")
end

local cwd = ""
-- Optional: Disable foreground process info in the right status bar
wezterm.on("update-status", function(window, pane)
    -- Workspace name
    local stat = window:active_workspace()
    local stat_color = "#f7768e"
    if window:active_key_table() then
        stat = window:active_key_table()
        stat_color = "#7dcfff"
    end
    if window:leader_is_active() then
        stat = "LDR"
        stat_color = "#bb9af7"
    end

    -- Current working directory
    local local_cwd = pane:get_current_working_dir()
    if local_cwd ~= nil then
        cwd = local_cwd and reduce_filepath(local_cwd.file_path)
    end

    -- -- Current command
    -- local cmd = pane:get_foreground_process_name()
    -- cmd = cmd and basename(cmd) or ""

    local tab_id = window:active_tab():tab_id()
    window:active_tab():set_title(string.format("Tab %d ", tab_id + 1))

    -- Time
    local time = wezterm.strftime("%H:%M:%S")

    -- Left status
    window:set_left_status(wezterm.format({
        { Background = { Color = scheme.tab_bar.background } },
        { Foreground = { Color = stat_color } },
        { Text = "  " },
        { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
        { Text = " " },
        { Background = { Color = scheme.tab_bar.background } },
        { Foreground = { Color = scheme.tab_bar.background } },
        { Text = wezterm.nerdfonts.ple_upper_left_triangle },
    }))

    -- Right status
    window:set_right_status(wezterm.format({
        { Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
        -- { Text = " | " },
        -- { Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
        -- "ResetAttributes",
        { Text = " | " },
        { Foreground = { Color = "#e0af68" } },
        { Text = wezterm.nerdfonts.md_clock .. "  " .. time },
        { Text = "  " },
    }))
end)

return config
