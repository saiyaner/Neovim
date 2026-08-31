-- VSCode-like buffer tab bar ('tabline').
--
-- Shows one tab per open real-file buffer (no [No Name], no special buffers
-- like the explorer/terminal/quickfix). Clicking a tab switches to it,
-- middle-click or clicking the 󰅖 icon closes it.
--
-- Click labels use the tabline `%{bufnr}@TablineHandle@` atom; the handler
-- receives (minwid, clicks, button, mods) from the C side.
local M = {}
local icons = require("ui.icons")

vim.cmd([[
  function! TablineHandle(bufnr, clicks, button, mods)
    call luaeval('require("statusline.tabline").handle(_A[1], _A[2], _A[3])', [a:bufnr, a:button, a:clicks])
    return 0
  endfunction
]])

-- Real file buffers only: listed, normal buftype, with a name, not a directory.
local function file_buffers()
  return vim.tbl_filter(function(b)
    if b.name == "" or (b.buftype or "") ~= "" then
      return false
    end
    -- Exclude directory buffers
    if vim.fn.isdirectory(b.name) == 1 then
      return false
    end
    -- Exclude explorer and other special buffers (already filtered by buftype, but double-check)
    local ft = vim.bo[b.bufnr].filetype
    if ft == "explorer" or ft == "netrw" or ft == "alpha" then
      return false
    end
    -- Only show file buffers that actually exist or are valid files (not stale)
    return true
  end, vim.fn.getbufinfo({ buflisted = 1 }))
end

-- Alternative: only show buffers visible in current tabpage windows (for "1 file only" mode)
local function visible_file_buffers()
  local seen = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.fn.isdirectory(name) == 0 and vim.bo[buf].filetype ~= "explorer" then
        seen[buf] = true
      end
    end
  end
  return vim.tbl_filter(function(b)
    return seen[b.bufnr]
  end, file_buffers())
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