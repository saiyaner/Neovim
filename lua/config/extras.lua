-- Extra quality-of-life tools (VSCode parity):
--   * trouble.nvim  : problems panel (Ctrl+Shift+M)
--   * dressing.nvim : nicer command-palette / input prompts (uses Telescope)
--   * lazygit.nvim  : git TUI (Ctrl+Alt+G)
local trouble = require("trouble")
trouble.setup({
  icons = true,
  fold_open = "▾",
  fold_closed = "▸",
  indent_lines = false,
  signs = { error = "󰅚", warning = "󰀪", hint = "󰌵", information = "󰋽" },
  use_diagnostic_signs = true,
})

vim.keymap.set("n", "<leader>xx", function() trouble.toggle("workspace_diagnostics") end,
  { desc = "Problems (workspace)" })
vim.keymap.set("n", "<leader>xX", function() trouble.toggle("document_diagnostics") end,
  { desc = "Problems (this file)" })
vim.keymap.set("n", "<leader>xr", function() trouble.toggle("lsp_references") end,
  { desc = "LSP references" })
vim.keymap.set("n", "<leader>xq", function() trouble.toggle("quickfix") end,
  { desc = "Quickfix list" })

-- Pretty vim.ui.select / input (command palette, inputs, etc.)
require("dressing").setup({
  select = { backend = "telescope", telescope = { theme = "dropdown" } },
  input = { enabled = true },
})

-- Lazygit TUI inside Neovim (registers the :LazyGit command on load)
local ok_lg, lazygit = pcall(require, "lazygit")
if ok_lg then
  vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Lazygit" })
end
