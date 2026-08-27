return {
    settings = {
        basedpyright = {
            disableOrganizeImports = true,
            typeCheckingMode = "standard",
            analysis = {
                diagnosticMode = "openFilesOnly",
                ignore = { "*" },
            },
        },
    },
}
