-- Neovim Config Entry Point
require("packer")

-- Load modules in order of initialization
require("lsp/lsp")          -- Initialize LSP server
require("ui/theme")         -- Set up UI and theme (Kitty)
require("explorer/explorer") -- File navigation
require("misc/misc")        -- Additional utilities
require("statusline")       -- Custom status line

-- Packer plugin manager
require("packer").load({
    config = function()
        vim.g.mapleader = " "
        
        -- Ensure LSP is ready before loading plugins
        require("lsp.lsp"):ready()
    end,
})

print("✓ Neovim configuration loaded successfully")
vim.cmd([[echo "# Neovim is configured" | nl]])
