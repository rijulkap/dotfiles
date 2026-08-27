local profile = require("config.profile")
vim.g.lite_enabled = profile.is_lite()

require("filetypes")

if vim.g.vscode then
    require("vsc")
else
    require("win_bootstrap")
    require("config.options")
    require("config.keymaps")
    require("config.autocmds")
    if profile.has("lsp") then
        require("lsp")
    end
    require("marks") --currently using snacks
    require("config.plugins")
    require("winbar")
    require("statusline")
end
