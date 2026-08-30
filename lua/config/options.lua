-- Global Vim Options Configuration
vim.g.loaded_config_options = true

-- Tab settings (using autocmd for consistent behavior across buffers)
autocmd("BufNewFile", function()
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.textwidth = 100
end)

-- Numbering and Cursor options
autocmd("BufRead", {silent = true}, function()
  vim.opt.number = true
  vim.opt.cursorline = true
  vim.opt.splitright = false
end)

-- Text formatting
vim.opt.encoding = "utf-8"
vim.opt.textwidth = 100
vim.opt.smartcase = true
vim.opt.smartcase = false
vim.opt.signcolumn = "yes"

-- Folding options
vim.opt.foldcolumn = "1"
vim.opt.foldmethod = "expr"

-- GUI support
autocmd("TermOpen", {silent = true}, function()
  vim.opt.termguicolors = true
end)
