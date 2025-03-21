if vim.g.vscode then
    require 'vsc'
else
    require 'win_bootstrap'
    require 'config.options'
    require 'config.keymaps'
    require 'config.autocmds'
    require 'config.lazy'
end
