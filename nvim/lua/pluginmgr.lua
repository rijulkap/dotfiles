local M = {}

local plugins = {}
local loaded = {}
local plugins_by_name = {}

local group = vim.api.nvim_create_augroup("LazyPlugins", { clear = true })
local build_group = vim.api.nvim_create_augroup("PluginBuildHooks", { clear = true })

local function run_job(command, cwd)
    local output = {}
    local function collect(_, data)
        for _, line in ipairs(data or {}) do
            if line ~= "" then
                table.insert(output, line)
            end
        end
    end

    local job = vim.fn.jobstart(command, {
        cwd = cwd,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = collect,
        on_stderr = collect,
    })
    if job <= 0 then
        error("failed to start build command")
    end

    local exit_code = vim.fn.jobwait({ job })[1]
    if exit_code ~= 0 then
        local details = #output > 0 and ("\n" .. table.concat(output, "\n")) or ""
        error(("build command exited with code %s%s"):format(exit_code, details))
    end
end

local function run_build(event)
    local build = event.spec.data and event.spec.data.build
    if not build then
        return
    end

    local needs_plugin = type(build) == "function" or (type(build) == "string" and vim.startswith(build, ":"))
    if needs_plugin and not event.active then
        vim.cmd.packadd(event.spec.name)
    end

    if type(build) == "function" then
        build(event)
    elseif type(build) == "string" then
        if vim.startswith(build, ":") then
            vim.cmd(build:sub(2))
        else
            run_job(build, event.path)
        end
    elseif type(build) == "table" then
        run_job(build, event.path)
    else
        error(("unsupported build hook type %q"):format(type(build)))
    end
end

vim.api.nvim_create_autocmd("PackChanged", {
    group = build_group,
    callback = function(event)
        if event.data.kind ~= "install" and event.data.kind ~= "update" then
            return
        end

        local ok, err = xpcall(run_build, debug.traceback, event.data)
        if not ok then
            vim.schedule(function()
                vim.notify(("Build failed for %s:\n%s"):format(event.data.spec.name, err), vim.log.levels.ERROR)
            end)
        end
    end,
})

local function load_plugin(plugin)
    local name = plugin.spec.name
    if loaded[name] then
        return
    end

    local data = plugin.spec.data or {}
    for _, dependency in ipairs(data.dependencies or {}) do
        local dependency_plugin = plugins_by_name[dependency]
        if not dependency_plugin then
            error(("Plugin %s depends on unknown plugin %s"):format(name, dependency))
        end
        load_plugin(dependency_plugin)
    end

    vim.cmd.packadd(name)

    -- Mark before setup so a callback cannot recursively configure the plugin.
    loaded[name] = true
    if data.config then
        data.config(plugin)
    end
end

local function as_list(value)
    if type(value) == "table" then
        return value
    end
    return value and { value } or {}
end

---@param plugin vim.pack.Spec
function M.add_plugin(plugin)
    table.insert(plugins, plugin)
end

function M.install_all()
    vim.pack.add(plugins, {
        load = function(plugin)
            local data = plugin.spec.data or {}
            local lazy = data.lazy == true

            plugins_by_name[plugin.spec.name] = plugin

            --Check Event Triggers
            if data.event then
                lazy = true
                vim.api.nvim_create_autocmd(data.event, {
                    group = group,
                    once = true,
                    pattern = data.pattern or "*",
                    callback = function()
                        load_plugin(plugin)
                    end,
                })
            end

            -- Command Triggers
            for _, command in ipairs(as_list(data.cmd)) do
                lazy = true
                vim.api.nvim_create_user_command(command, function(cmd_args)
                    pcall(vim.api.nvim_del_user_command, command)
                    load_plugin(plugin)
                    vim.api.nvim_cmd({
                        cmd = command,
                        args = cmd_args.fargs,
                        bang = cmd_args.bang,
                        range = cmd_args.range ~= 0 and { cmd_args.line1, cmd_args.line2 } or nil,
                        count = cmd_args.count ~= -1 and cmd_args.count or nil,
                    }, {})
                end, {
                    nargs = data.nargs,
                    range = data.range,
                    bang = data.bang,
                    complete = data.complete,
                    count = data.count,
                })
            end

            -- Key triggers are temporary mappings. Once the plugin is loaded,
            -- its real mapping replaces them and the original key is replayed.
            for _, key in ipairs(data.keys or {}) do
                lazy = true
                local mode = key.mode or "n"
                local lhs = key[1] or key.lhs
                vim.keymap.set(mode, lhs, function()
                    vim.keymap.del(mode, lhs)
                    load_plugin(plugin)
                    vim.api.nvim_feedkeys(vim.keycode(lhs), "m", false)
                end, { desc = key.desc })
            end

            if lazy == false then
                load_plugin(plugin)
            end
        end,
    })
end

return M
