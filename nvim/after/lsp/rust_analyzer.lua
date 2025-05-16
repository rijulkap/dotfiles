return {
    settings = {
        ["rust-analyzer"] = {
            checkOnSave = {
                enable = true,
            },
            diagnostics = {
                enable = true, -- keep LSP semantic diagnostics
            },
        },
    },
}
