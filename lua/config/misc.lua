-- Autopairs: auto-close brackets/quotes (with LSP completion integration)
local ok_ap, ap = pcall(require, "nvim-autopairs")
if ok_ap then
  ap.setup({
    check_ts = true, -- respect tree-sitter
    disable_filetype = { "explorer", "netrw", "TelescopePrompt" },
  })
  local cmp_ap = require("nvim-autopairs.completion.cmp")
  require("cmp").event:on("confirm_done", cmp_ap.on_confirm_done())
end

-- Comments: gcc (toggle line), gc + motion (VSCode Ctrl+/ style)
require("Comment").setup()

-- Indent guides (like VSCode indent guides)
require("ibl").setup({
  indent = { char = "│" },
  scope = { enabled = true, char = "▏" },
  exclude = {
    filetypes = { "explorer", "netrw", "lspinfo", "checkhealth", "help", "man" },
    buftypes = { "nofile" },
  },
})

-- Surround: ys (add), ds (delete), cs (change) — e.g. ysiw" wraps word in quotes
require("nvim-surround").setup()

-- Auto-close HTML/XML/JSX tags (like VSCode auto close tag)
local ok_at, autotag = pcall(require, "nvim-ts-autotag")
if ok_at then
  autotag.setup({})
end

-- TODO/FIXME/HACK comments (like VSCode TODO tree)
require("todo-comments").setup({
  signs = false,
  highlight = { before = "", keyword = "wide" },
  search = { pattern = [[\b(KEYWORDS)\b]] },
})

vim.keymap.set("n", "<leader>t", "<cmd>TodoTelescope<CR>", { desc = "TODO list" })