vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Netrw is disabled: we use our own file explorer (with icons) instead
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.theme")
require("config.tabline")
require("config.lsp")
require("config.completion")
require("config.telescope")
require("config.whichkey")
require("config.marks")
require("config.session")
require("config.gitsigns")
require("config.misc")
require("config.editing")
require("config.dashboard")
require("config.extras")

-- `nvim <dir>` opens the custom file tree (netrw is disabled)
local dir_arg = vim.fn.argv()[1]
if dir_arg and vim.fn.isdirectory(dir_arg) == 1 then
  local dir_buf = vim.api.nvim_get_current_buf()
  vim.defer_fn(function()
    vim.cmd.cd(vim.fn.fnameescape(dir_arg))
    require("config.explorer").open_here()
    -- wipe the leftover directory buffer so it never shows up as a tab
    pcall(vim.api.nvim_buf_delete, dir_buf, { force = true })
  end, 10)
end

-- The initial empty buffer (bare `nvim`) must never show as a tab or as
-- "[No Name]" anywhere. Skip the dashboard buffer (it is intentionally unnamed).
vim.defer_fn(function()
  local b = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(b) == "" and vim.bo[b].filetype ~= "alpha" then
    vim.bo[b].buflisted = false
  end
end, 50)