-- Editing power-tools (VSCode-like extras):
--   grug-far   : global find & replace with live preview (VSCode Ctrl+Shift+H)
--   illuminate : highlight word occurrences under the cursor (VSCode built-in)
--   undotree   : undo history timeline (VSCode timeline)
--   colorizer  : inline hex-color preview
--   visual-multi: multi-cursor editing (VSCode Ctrl+D / Alt+Click)

-- Global find & replace with live preview
local ok_gf, grug = pcall(require, "grug-far")
if ok_gf then
  grug.setup({
    transient = false,
  })
  vim.keymap.set("n", "<leader>fr", function()
    grug.open({ prefills = { search = vim.fn.expand("<cword>") } })
  end, { desc = "Find & replace (global)" })
end

-- Highlight all occurrences of the word under the cursor
local ok_il, illum = pcall(require, "illuminate")
if ok_il then
  illum.configure({
    under_cursor = true,
    delay = 150,
    filetypes_denylist = {
      "explorer", "netrw", "TelescopePrompt", "undotree", "grug-far",
      "help", "checkhealth", "lspinfo",
    },
    large_file_cutoff = 2500,
    large_file_overrides = { providers = { "lsp" } },
  })
end

-- Undo history panel
vim.g.undotree_SplitWidth = 30
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_DiffAutoOpen = 1
vim.g.undotree_DiffpanelHeight = 12
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undo history" })

-- Inline color preview (hex codes, CSS functions)
local ok_cz, colorizer = pcall(require, "colorizer")
if ok_cz then
  colorizer.setup(nil, {
    RGB = true,
    RRGGBB = true,
    RRGGBBAA = true,
    AARRGGBB = true,
    css_fn = true,
    mode = "background",
  })
end

-- Multi-cursor: <C-n> add next occurrence, <C-Down>/<C-Up> add cursor below/above,
-- Ctrl+Click add cursor at position (VSCode Alt+Click style)
vim.g.VM_default_mappings = 1
vim.g.VM_mouse_mappings = 1

-- Flash: jump to any visible character (AceJump-style, 2 keys)
local ok_fl, flash = pcall(require, "flash")
if ok_fl then
  flash.setup({
    modes = {
      char = { jump_labels = true },
      search = { enabled = true },
    },
    highlight = { backdrop = true },
  })
  vim.keymap.set({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash: jump to char" })
  vim.keymap.set("o", "S", flash.treesitter, { desc = "Flash: select treesitter node" })
  vim.keymap.set("n", "<leader>fj", flash.treesitter, { desc = "Flash: treesitter jump" })
end