-- Fat cursor
-- vim.opt.guicuror = ""

vim.opt.nu = true;
vim.opt.relativenumber = true;

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.wo.wrap = false
vim.wo.linebreak = false

vim.opt.smartindent = true

vim.opt.swapfile = false;
vim.opt.backup = false;

local OS = vim.loop.os_uname().sysname
if (OS == 'Linux') then
	vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
elseif (OS:find 'Windows') then
	vim.opt.undodir = os.getenv("USERPROFILE") .. "/.vim/undodir"
end
vim.opt.undofile = true;

vim.opt.hlsearch = false;
vim.opt.incsearch = true;

vim.opt.termguicolors = true;

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.g.mapleader = " "
