return {
    settings = {
        Lua = {
            -- completion = { callSnippet = "Replace" },
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
