-- Which-Key: press <leader> (space) to see all keymaps, VSCode-style discoverability.
local wk = require("which-key")

wk.setup({
  win = {
    border = "rounded",
    padding = { 1, 2, 1, 2 },
  },
  show_help = false,
})

wk.add({
  { "<leader>e", desc = "File explorer" },
  { "<leader>x", desc = "Close buffer" },
  { "<leader>p", desc = "Find files (Ctrl+P)" },
  { "<leader>f", desc = "Find in files (grep)" },
  { "<leader>b", desc = "Buffers" },
  { "<leader>r", desc = "Recent files" },
  { "<leader>m", desc = "Marks" },
  { "<leader>s", desc = "Symbols" },
  { "<leader>t", desc = "TODO list" },
  { "<leader>d", desc = "Diagnostics" },
  { "<leader>g", desc = "Git", group = "git" },
  { "<leader>gp", desc = "Preview hunk" },
  { "<leader>gs", desc = "Stage hunk" },
  { "<leader>gr", desc = "Reset hunk" },
  { "<leader>gb", desc = "Blame line" },
  { "<leader>gd", desc = "Diff this file" },
  { "<leader>q", desc = "Quickfix / session", group = "quickfix" },
  { "<leader>qs", desc = "Save session" },
  { "<leader>ql", desc = "Load session" },
  { "<leader>qd", desc = "Don't save session" },
  { "<leader>Q", desc = "Close quickfix" },
  { "<leader>x", desc = "Trouble", group = "trouble" },
  { "<leader>xx", desc = "Problems (workspace)" },
  { "<leader>xX", desc = "Problems (this file)" },
  { "<leader>xr", desc = "LSP references" },
  { "<leader>xq", desc = "Quickfix list" },
  { "<leader>gg", desc = "Lazygit" },
  { "<leader>cf", desc = "Format document" },
})