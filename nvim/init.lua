vim.g.lite_enabled = vim.env.NVIM_LITE == "true"

require("filetypes")

if vim.g.vscode then
    require("vsc")
else
    require("win_bootstrap")
    require("config.options")
    require("config.keymaps")
    require("config.autocmds")
    if not vim.g.lite_enabled then
        require("lsp")
    end
    -- require("marks") --currently using snacks
    require("config.plugins")
    require("winbar")
    require("statusline")
end
