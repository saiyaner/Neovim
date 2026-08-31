-- Leader must be set before any keymaps (space = VSCode style)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Silence deprecated warnings (vim.tbl_flatten etc. from old plugins)
vim.deprecate = function() end
-- Compatibility shim: some plugins still call vim.tbl_flatten
if vim.tbl_flatten then
  local _orig_flatten = vim.tbl_flatten
  vim.tbl_flatten = function(t)
    if vim.iter then
      return vim.iter(t):flatten():totable()
    end
    -- fallback without deprecation notice
    local ok, res = pcall(_orig_flatten, t)
    return ok and res or t
  end
end

-- Disable netrw (we use custom explorer)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

-- Neovim Config Entry Point

-- Load core configuration first
require("config.options")
require("config.keymaps")

-- Load UI and theme
require("ui.theme")
require("ui.dashboard")
require("ui.icons")

-- Load LSP and completion
require("lsp.lsp")
require("lsp.completion")
require("lsp.gitsigns")

-- Load explorer
require("explorer")

-- Load misc modules
require("misc.autocmds")
require("misc.editing")
require("misc.extras")
require("misc.marks")
require("misc.misc")
require("misc.options")
require("misc.session")
require("misc.telescope")
require("misc.keymaps")
require("misc.whichkey")

-- Load statusline and tabline
require("statusline")