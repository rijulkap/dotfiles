local selected_solutions = {}

local function targets_in(root_dir)
    local solutions = {}
    local projects = {}

    for name, kind in vim.fs.dir(root_dir) do
        if kind == "file" then
            local path = vim.fs.joinpath(root_dir, name)
            if name:match("%.slnx?$") then
                table.insert(solutions, path)
            elseif name:match("%.csproj$") then
                table.insert(projects, path)
            end
        end
    end

    table.sort(solutions)
    table.sort(projects)
    return solutions, projects
end

local function open_solution(client, solution)
    selected_solutions[client.config.root_dir] = solution
    vim.notify("Initializing: " .. vim.fs.basename(solution), vim.log.levels.INFO, { title = "roslyn" })
    client:notify("solution/open", { solution = vim.uri_from_fname(solution) })
end

local function on_init(client)
    local root_dir = client.config.root_dir
    local solutions, projects = targets_in(root_dir)

    if #solutions == 0 then
        if #projects > 0 then
            client:notify("project/open", {
                projects = vim.tbl_map(vim.uri_from_fname, projects),
            })
        end
        return
    end

    local selected = selected_solutions[root_dir]
    if selected and vim.fn.filereadable(selected) == 1 then
        open_solution(client, selected)
        return
    end

    if #solutions == 1 then
        open_solution(client, solutions[1])
        return
    end

    vim.ui.select(solutions, {
        prompt = "Select Roslyn solution:",
        format_item = vim.fs.basename,
    }, function(solution)
        if solution then
            open_solution(client, solution)
        end
    end)
end

-- Override nvim-lspconfig's native Roslyn config after its defaults load.
local config = {
    on_init = on_init,
    settings = {
        ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
        },
    },
}

local function switch_target()
    local bufnr = vim.api.nvim_get_current_buf()
    local client = vim.lsp.get_clients({ name = "roslyn_ls", bufnr = bufnr })[1]
    if not client then
        vim.notify("Roslyn is not attached to this buffer", vim.log.levels.WARN, { title = "roslyn" })
        return
    end

    local solutions = targets_in(client.config.root_dir)
    if #solutions == 0 then
        vim.notify("No solution files found", vim.log.levels.WARN, { title = "roslyn" })
        return
    end

    vim.ui.select(solutions, {
        prompt = "Select Roslyn target:",
        format_item = function(solution)
            return vim.fn.fnamemodify(solution, ":.")
        end,
    }, function(solution)
        if not solution then
            return
        end

        local root_dir = vim.fs.dirname(solution)
        selected_solutions[root_dir] = solution

        local target_config = vim.deepcopy(client.config)
        target_config.root_dir = root_dir
        target_config.on_init = function(new_client)
            open_solution(new_client, solution)
        end

        local force_stop = vim.uv.os_uname().sysname == "Windows_NT"
        client:stop(force_stop)

        local attempts = 0
        local function start_when_stopped()
            attempts = attempts + 1
            if vim.lsp.get_client_by_id(client.id) and attempts < 100 then
                vim.defer_fn(start_when_stopped, 50)
                return
            end

            if vim.lsp.get_client_by_id(client.id) then
                client:stop(true)
            end
            vim.lsp.start(target_config, { bufnr = bufnr })
        end

        vim.defer_fn(start_when_stopped, 50)
    end)
end

vim.api.nvim_create_user_command("Roslyn", function(command)
    if command.args == "target" then
        switch_target()
        return
    end

    vim.notify("Unknown Roslyn command: " .. command.args, vim.log.levels.ERROR, { title = "roslyn" })
end, {
    nargs = 1,
    complete = function(arg_lead)
        return vim.startswith("target", arg_lead) and { "target" } or {}
    end,
    desc = "Manage the native Roslyn language server",
})

return config
