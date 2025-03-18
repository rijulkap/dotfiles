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

config.font = wezterm.font_with_fallback({
    { family = "JetBrainsMono Nerd Font", scale = 1.0, weight = "Medium" },
})

config.window_background_opacity = 0.95
-- config.window_decorations = "RESIZE"
-- config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "main"

config.max_fps = 240

-- local last_cwd = wezterm.home_dir

-- wezterm.on("spawn-new-tab", function(tab)
-- 	tab:set_cwd(last_cwd)
-- end)

-- wezterm.on("spawn-new-pane", function(pane)
-- 	pane:set_cwd(last_cwd)
-- end)

-- Keys
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
    { key = "c", mods = "LEADER", action = act.ActivateCopyMode },
    { key = "phys:Space", mods = "LEADER", action = act.ActivateCommandPalette },
    { key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
    { key = "w", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
    { key = "q", mods = "LEADER", action = act.QuitApplication },
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    { key = "o", mods = "LEADER", action = act.RotatePanes("Clockwise") },
    { key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
    { key = "n", mods = "LEADER", action = act.ShowTabNavigator },
    { key = "Enter", mods = "LEADER", action = act.ToggleFullScreen },
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
        { key = "Enter", action = "PopKeyTable" },
    },
    move_tab = {
        { key = "h", action = act.MoveTabRelative(-1) },
        { key = "l", action = act.MoveTabRelative(1) },
        { key = "Escape", action = "PopKeyTable" },
        { key = "Enter", action = "PopKeyTable" },
    },
}

-- Tab bar configuration
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false

-- Disable dynamic tab naming by not setting foreground process as tab name
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    -- Use a static title or base it on the tab index
    return string.format(" Tab %d |", tab.tab_id + 1)
end)

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
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
    local cwd = pane:get_current_working_dir()
    cwd = cwd and reduce_filepath(cwd.file_path)

    -- -- Current command
    -- local cmd = pane:get_foreground_process_name()
    -- cmd = cmd and basename(cmd) or ""

    local tab_id = window:active_tab():tab_id()
    window:active_tab():set_title(string.format("Tab %d ", tab_id + 1))

    -- Time
    local time = wezterm.strftime("%H:%M:%S")

    -- Left status
    window:set_left_status(wezterm.format({
        { Foreground = { Color = stat_color } },
        { Text = "  " },
        { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
        { Text = " |" },
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
