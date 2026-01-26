vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.cmd("set number")

vim.g.mapleader = " "
vim.wo.relativenumber = true
vim.o.undofile = true

vim.cmd("set clipboard=unnamedplus")

-- Set filetype for Arduino files
vim.cmd("autocmd BufNewFile,BufRead *.ino set filetype=arduino")

-- Suppress verbose messages
vim.opt.shortmess:append("c") -- Don't show completion messages
vim.opt.shortmess:append("F") -- Don't show file info when editing
vim.opt.cmdheight = 1 -- Keep command line height minimal
