vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 1
vim.opt.mouse = "a"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- vim.opt.signcolumn = "yes:2"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "nosplit"
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.splitkeep = "screen"
vim.opt.sidescrolloff = 8
vim.opt.hidden = true
vim.opt.wrap = false
vim.opt.showcmd = false
vim.opt.clipboard = "unnamedplus"
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true, F = true })
vim.opt.showmode = false -- Dont show mode since we have a statusline
vim.opt.cursorline = true
vim.opt.smoothscroll = true
vim.opt.termguicolors = true -- Enable true colors
vim.opt.confirm = true
vim.opt.shada = [['20,<10,s5,h]]

-- -- Open all folds by default, zm is not available
vim.opt.foldlevelstart = 99
-- vim.opt.statuscolumn = "%s%l "
