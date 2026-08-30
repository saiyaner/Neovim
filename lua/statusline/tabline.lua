-- VSCode-like buffer tab bar ('tabline').
--
-- Shows one tab per open real-file buffer (no [No Name], no special buffers
-- like the explorer/terminal/quickfix). Clicking a tab switches to it,
-- middle-click or clicking the 󰅖 icon closes it.
--
-- Click labels use the tabline `%{bufnr}@TablineHandle@` atom; the handler
-- receives (minwid, clicks, button, mods) from the C side.
local M = {}
local icons = require("config.icons")

vim.cmd([[
  function! TablineHandle(bufnr, clicks, button, mods)
    call luaeval('require("config.tabline").handle(_A[1], _A[2], _A[3])', [a:bufnr, a:button, a:clicks])
    return 0
  endfunction
]])

-- Real file buffers only: listed, normal buftype (nil or ""), with a name.
local function file_buffers()
  return vim.tbl_filter(function(b)
    return b.name ~= "" and (b.buftype or "") == ""
  end, vim.fn.getbufinfo({ buflisted = 1 }))
end

-- Called by the tabline click handler.
function M.handle(bufnr, button, clicks)
  if bufnr <= 0 then
    return
  end
  if button == "m" or (button == "l" and clicks == 2) then
    M.close_buf(bufnr)
  elseif button == "l" then
    vim.api.nvim_set_current_buf(bufnr)
  end
end

-- Close a buffer. If it was the last file buffer, leave a clean empty
-- (unlisted) buffer behind so no tab and no [No Name] ever shows.
-- Unsaved changes are never discarded silently: the close is aborted.
function M.close_buf(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  if vim.bo[bufnr].modified then
    return
  end
  local others = vim.tbl_filter(function(b)
    return b.bufnr ~= bufnr
  end, file_buffers())
  if #others == 0 then
    vim.cmd("enew")
    vim.bo.buflisted = false
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  else
    pcall(vim.cmd.bdelete, bufnr)
  end
end

-- Switch to the Nth file buffer (tab). Used by Alt+1..9.
function M.goto_tab(n)
  local buffers = file_buffers()
  if buffers[n] then
    vim.api.nvim_set_current_buf(buffers[n].bufnr)
  end
end

function M.tabline()
  local parts = {}
  local active = vim.api.nvim_get_current_buf()
  local buffers = file_buffers()
  for i, b in ipairs(buffers) do
    local name = vim.fn.fnamemodify(b.name, ":t")
    local icon = icons.for_name(name)[1]
    local modified = vim.bo[b.bufnr].modified and " 󰄉" or ""
    local group = b.bufnr == active and "TabActive" or "TabInactive"
    table.insert(parts, ("%%%d@TablineHandle@%%#%s# %d %s %s%s %%#TabClose#󰅖%%#%s#%%X%%#TabLineFill#  "):format(
      b.bufnr, group, i, icon, name, modified, group))
  end
  return table.concat(parts) .. "%="
end

return M