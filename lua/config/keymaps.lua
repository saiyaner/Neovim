local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Switch to other buffer" })

-- File explorer (custom, with icons)
map("n", "<leader>e", "<cmd>lua require('config.explorer').toggle()<CR>", { desc = "Toggle file explorer" })

-- Move lines / selections
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("n", "J", "mzJ`z", { desc = "Join lines" })

-- Better indenting in visual mode
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Keep cursor centered when jumping
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous match (centered)" })

-- Close current buffer (VSCode: close tab)
map("n", "<leader>x", function()
  require("config.tabline").close_buf(0)
end, { desc = "Close current buffer" })

-- Switch tabs with Alt+1..9 (VSCode-style)
for i = 1, 9 do
  map("n", ("<M-%d>"):format(i), function()
    require("config.tabline").goto_tab(i)
  end, { desc = ("Go to tab %d"):format(i) })
end

-- Diagnostics (LSP/built-in)
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Format document (VSCode: Shift+Alt+F)
map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format document" })

-- Quickfix
map("n", "<leader>q", "<cmd>copen<CR>", { desc = "Open quickfix" })
map("n", "<leader>Q", "<cmd>cclose<CR>", { desc = "Close quickfix" })

-- VSCode-like: Ctrl+P find files, Ctrl+S save
local tb = require("telescope.builtin")
map("n", "<C-p>", tb.find_files, { desc = "Find files" })
map("n", "<leader>p", tb.find_files, { desc = "Find files" })
map("n", "<C-s>", vim.cmd.write, { desc = "Save file" })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save file" })
map("n", "<leader>f", tb.live_grep, { desc = "Find in files (grep)" })
map("n", "<leader>b", tb.buffers, { desc = "Buffers" })
map("n", "<leader>r", tb.oldfiles, { desc = "Recent files" })
map("n", "<leader>m", tb.marks, { desc = "Marks" })
map("n", "<leader>s", tb.lsp_document_symbols, { desc = "Symbols" })
map("n", "<leader>gs", tb.git_status, { desc = "Git status" })

-- More pickers (VSCode parity)
map("n", "<leader>:", tb.commands, { desc = "Command palette (Ctrl+Shift+P)" })
map("n", "<leader>cd", tb.git_branches, { desc = "Git branches" })
map("n", "<leader>di", tb.diagnostics, { desc = "Diagnostics (problems)" })
map("n", "<leader>fl", tb.current_buffer_fuzzy_find, { desc = "Lines in buffer (Ctrl+G)" })

-- Window splits (VSCode Ctrl+\ style)
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>w=", "<cmd>wincmd =<CR>", { desc = "Equalize windows" })
map("n", "<leader>wo", "<cmd>only<CR>", { desc = "Close other windows" })

-- Sessions (VSCode-like workspace memory)
map("n", "<leader>qs", function() require("persistence").save() end, { desc = "Save session" })
map("n", "<leader>ql", function() require("persistence").load() end, { desc = "Load session" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't save session" })