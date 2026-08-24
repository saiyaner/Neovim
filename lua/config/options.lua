local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor & scrolling
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Editing
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.swapfile = false
opt.completeopt = "menu,menuone,noselect"
opt.formatoptions = "jcroqlnt"

-- Window behavior
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.showmode = false
opt.signcolumn = "yes"
opt.wrap = false
opt.linebreak = true

-- Display
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.inccommand = "split"
opt.fillchars = { eob = " " }

-- Timing
opt.updatetime = 250
opt.timeoutlen = 400

-- Statusline + winbar + tab bar
opt.laststatus = 2
opt.statusline = "%!v:lua.require('config.statusline').statusline()"
opt.winbar = "%!v:lua.require('config.statusline').winbar()"
opt.showtabline = 2
opt.tabline = "%!v:lua.require('config.tabline').tabline()"