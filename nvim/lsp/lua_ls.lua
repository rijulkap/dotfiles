return {
    settings = {
        Lua = {
            completion = { callSnippet = "Replace" },
            diagnostics = {
                -- Diagnose open files without repeatedly scanning the workspace.
                workspaceDelay = -1,
            },
            -- Using stylua for formatting.
            format = { enable = false },
            hint = {
                enable = true,
                arrayIndex = "Disable",
            },
            runtime = {
                version = "LuaJIT",
            },
        },
    },
}
