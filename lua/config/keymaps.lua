-- Custom Keybinds Configuration (non-conflicting with misc/keymaps)
vim.g.loaded_config_keymaps = true

-- LSP quick fixes (use leader variants to avoid clashing with window nav C-h/C-j)
vim.keymap.set("n", "<leader>qf", function() vim.lsp.buf.code_action({ actionItem = "Fix All" }) end, { desc = "Quick Fix (LSP)" })
vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, { desc = "LSP Format" })

-- Explorer is handled via <leader>e in misc/keymaps (space+e)
-- Close explorer is handled by 'q' inside explorer buffer
