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
require("plugins.treesitter")

-- LSP and Formatter
require("plugins.conform")
require("plugins.lsp")

-- Git
require("plugins.gitsigns")

-- Completion
require("plugins.luasnip")
require("plugins.blink")

-- UI
require("plugins.bufferline")
require("plugins.lualine")
require("plugins.markdown-stuff")

-- explorer
require("plugins.oil")

--misc
require("plugins.flash")

-- Resolve untracked Extras
require("plugins.Extras")

-- load once to install all plugins 
require("pluginmgr").install_all()
