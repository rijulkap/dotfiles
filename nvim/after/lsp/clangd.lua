if vim.env.ESP_IDF_VERSION then
    local cmd = {
        "/home/rk-dev/.espressif/tools/esp-clang/16.0.1-fe4f10a809/esp-clang/bin/clangd",
        "--background-index",
        "--query-driver=**",
    }
    return {
        cmd = cmd,
    }
end

return {
    cmd = {
        "clangd",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--fallback-style=none",
        "--function-arg-placeholders=false",
    },
}
