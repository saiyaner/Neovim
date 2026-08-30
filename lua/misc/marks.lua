-- Bookmarks / place markers (like VSCode bookmarks):
--   m;        toggle bookmark at cursor
--   m[ / m]   previous / next mark
--   m{ / m}   previous / next bookmark
--   m:        preview (jump and flash) the mark under cursor
require("marks").setup({
  default_mappings = true,
  excluded_filetypes = { "explorer", "netrw" },
  excluded_buftypes = { "nofile" },
})