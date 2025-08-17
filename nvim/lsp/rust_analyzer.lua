return {
    settings = {
        ["rust-analyzer"] = {
            completion = {
                callable = {
                    snippets = "add_parentheses",
                },
            },
            checkOnSave = {
                enable = true,
            },
            diagnostics = {
                enable = true, -- keep LSP semantic diagnostics
            },
        },
    },
}
