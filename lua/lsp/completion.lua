-- VSCode-like completion menu: Codeium (AI) + LSP + buffer + path + snippets.
-- Type -> menu pops up -> pick with <C-n>/<C-p> or arrows -> Enter accepts.
-- Tab = expand snippet / jump to next placeholder (VSCode-style).
local cmp = require("cmp")
local codeium = require("codeium")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()

codeium.setup({
  enable_cmp_source = true,
  virtual_text = {
    enabled = true,
    manual = false,   -- auto: suggestion muncul setelah jeda mengetik (VSCode style)
    idle_delay = 100, -- ms setelah berhenti mengetik -> ghost text muncul
    map_keys = false, -- Tab di-handle manual di bawah (biar kompatibel cmp/luasnip)
  },
})

local kind_icons = {
  Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "󰆧", Field = "󰜢",
  Variable = "󰈀", Class = "󰌗", Interface = "󰕘", Module = "󰅩", Property = "󰜢",
  Unit = "󰑭", Value = "󰎠", Enum = "󰒻", Keyword = "󰌋", Snippet = "󰘃",
  Color = "󰏘", File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "󰒻",
  Constant = "󰏿", Struct = "󰙅", Event = "󰅆", Operator = "󰆕", TypeParameter = "󰊄",
  Codeium = "󱂅",
}

local function format_kind(entry, vim_item)
  vim_item.kind = (kind_icons[vim_item.kind] or "󰂚") .. " " .. vim_item.kind
  vim_item.kind_hl_group = "CmpKind"
  return vim_item
end

cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = format_kind,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter = pilih (seperti VSCode)
    ["<Tab>"] = cmp.mapping(function(fallback)
      -- VSCode-style: Tab = terima ghost text Codeium kalau lagi muncul
      local ok_vt, vt = pcall(require, "codeium.virtual_text")
      if ok_vt and vt.get_current_completion_item() then
        local keys = vt.accept()
        if keys and keys ~= "" then
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
          return
        end
      end
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  }),
  sources = cmp.config.sources({
    { name = "codeium", priority = 100, group_index = 1 },
    { name = "nvim_lsp", priority = 90 },
    { name = "luasnip", keyword_length = 2 },
    { name = "buffer", keyword_length = 2 },
    { name = "path" },
  }),
  sorting = {
    priority_weight = 2,
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
})

-- Codeium ghost text: siklus saran alternatif (VSCode: Ctrl+Alt+] / Ctrl+Alt+[)
vim.keymap.set("i", "<M-]>", function()
  local ok_vt, vt = pcall(require, "codeium.virtual_text")
  if ok_vt then vt.cycle_completions(1) end
end, { silent = true, desc = "Codeium: saran berikutnya" })

vim.keymap.set("i", "<M-[>", function()
  local ok_vt, vt = pcall(require, "codeium.virtual_text")
  if ok_vt then vt.cycle_completions(-1) end
end, { silent = true, desc = "Codeium: saran sebelumnya" })

-- CmpItemKind* colors are owned by config.theme (they follow the terminal accent).

-- luacnv.lsp integration: refactor and fix triggered by <leader>la / <leader>lfa
local luacnv = pcall(require, "luacnv")
if luacnv then
  local function get_source()
    return cmp.get_active_document_selection() or vim.bo.filetype == "typescript" and "lua"
  end

  local refactor_cmds = {
    "add_return", "remove_braces", "use_async", "extract_method", "inline_method",
    "convert_to_array_literal", "replace_function_with_method",
    "move_block_of_code_up", "move_block_of_code_down",
  }

  vim.keymap.set("n", "<leader>la", function()
    local source = get_source()
    luacnv.refactor_lsp({ source = source, cmds = refactor_cmds })
    cmp.confirm({ select = true })
  end, { desc = "Lua: Refactor (luacnv)" })

  vim.keymap.set("n", "<leader>lfa", function()
    local source = get_source()
    luacnv.fix_lsp({ source = source, fixers = {} })
    cmp.confirm({ select = true })
  end, { desc = "Lua: Fix (luacnv)" })
end