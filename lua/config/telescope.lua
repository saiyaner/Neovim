-- VSCode-like fuzzy finder: Ctrl+P (files), live grep, buffers, recent, symbols.
-- Prompt on top, dropdown layout — like VSCode's quick open.
local telescope = require("telescope")

local ok, fzf = pcall(telescope.load_extension, "fzf")
if not ok then
  vim.notify("telescope-fzf-native not built, using Lua sorter", vim.log.levels.WARN)
end

telescope.setup({
  defaults = {
    sorting_strategy = "ascending", -- prompt on top (VSCode-like)
    prompt_prefix = "󰊄 ",
    selection_caret = "󰄾 ",
    file_ignore_patterns = { "^%.git/", "node_modules/", "target/", "%.lock", "%.log" },
    layout_config = {
      prompt_position = "top",
    },
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  },
  pickers = {
    find_files = { theme = "dropdown", layout_config = { width = 0.6, height = 0.45 } },
    live_grep = { theme = "dropdown", layout_config = { width = 0.6, height = 0.45 } },
    buffers = { theme = "dropdown", layout_config = { width = 0.6, height = 0.45 } },
    oldfiles = { theme = "dropdown", layout_config = { width = 0.6, height = 0.45 } },
    git_status = { theme = "dropdown", layout_config = { width = 0.6, height = 0.45 } },
    lsp_document_symbols = { theme = "dropdown", layout_config = { width = 0.6, height = 0.45 } },
  },
})