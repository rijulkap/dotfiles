if vim.g.vscode then
    require("vsc")
else
    require("win_bootstrap")
    require("config.options")
    require("config.keymaps")
    require("config.autocmds")
    require("lsp")
    -- require("marks") --currently using snacks
    require("config.lazy")
    require("winbar")
end
