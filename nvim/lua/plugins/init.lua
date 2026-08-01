local profile = require("config.profile")

-- Load inbuilt plugins
vim.cmd("packadd nvim.difftool")
vim.cmd("packadd nvim.undotree")

require("plugins.colorschemes")

-- Snacks
require("plugins.snacks")

-- Whichkey
require("plugins.which-key")

-- Mini
require("plugins.mini")

-- Treesitter
if profile.has("treesitter") then
    require("plugins.treesitter")
end

-- LSP and Formatter
if profile.has("formatting") then
    require("plugins.conform")
end
if profile.has("lsp") then
    require("plugins.lsp")
end
if profile.has("debugging") then
    require("plugins.dap")
end

-- Git
require("plugins.gitsigns")

-- Completion
require("plugins.luasnip")
require("plugins.blink")

-- UI
require("plugins.bufferline")
require("plugins.lualine")
if profile.has("treesitter") then
    require("plugins.markdown-stuff")
end

-- explorer
require("plugins.oil")

--misc
require("plugins.flash")

-- Resolve untracked Extras
require("plugins.Extras")

-- load once to install all plugins 
require("pluginmgr").install_all()
