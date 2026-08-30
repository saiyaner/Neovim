-- Custom Keybinds Configuration
vim.g.loaded_config_keymaps = true

-- Navigation shortcuts
vim.keymap.set("n", "<C-h>", function() vim.lsp.buf.code_action({ actionItem = "Fix All" }) end, { desc = "Quick Fix (LSP)" })
vim.keymap.set("n", "<C-j>", function() vim.lsp.buf.rangeFormatting(0, -1) end, { desc = "Format Selection" })

-- Buffer navigation
vim.keymap.set("n", "<C-k>", function() require("explorer").jumpUp() end, { desc = "Explorer Up" })
vim.keymap.set("n", "<C-l>", function() require("explorer").jumpDown() end, { desc = "Explorer Down" })

-- Editor actions
vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format {} end, { desc = "LSP Format" })
vim.keymap.set("n", "<leader>q", function() require("explorer").close() end, { desc = "Close Tab" })
