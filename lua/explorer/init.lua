-- VSCode-like file explorer (no plugins).
--
-- Layout invariants:
--   1. At most ONE explorer window per session.
--   2. Always the LEFTMOST window, fixed at 30% width (winfixwidth).
--   3. Opening a file never replaces the explorer: it opens in an existing
--      editor window or a new one to the right, then the tree closes.
--   4. Closing the explorer closes only the explorer window.
--
-- Tree behavior (drop-down like VSCode):
--   - Directories expand/collapse in place; children are indented below.
--   - Expansion state is remembered per directory path.
--   - h/<BS> moves the tree root up one level.
--
-- Keys:
--   <CR>/l  dir -> expand/collapse, file -> open (tree closes)
--   h/<BS>  tree root up one level
--   a       create file/folder (name ending in "/" creates a folder)
--   r       rename selected file/folder
--   d       delete selected file/folder (asks for confirmation)
--   R       refresh
--   H       toggle hidden files
--   q       close
local M = {}
local icons = require("ui.icons")

local ns = vim.api.nvim_create_namespace("explorer")

local state = { buf = nil, win = nil, dir = nil, show_hidden = false }
local meta = {}    -- line (below header) -> node
local expanded = {} -- path -> true; remembered across renders
local git_status_cache = {} -- path -> git status

local function tree_width()
  return math.max(30, math.floor(vim.o.columns * 0.3))
end

-- The window currently showing the explorer buffer (looked up by buffer, so a
-- stale window handle can never be trusted).
local function explorer_win()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_buf(w) == state.buf then
        return w
      end
    end
  end
  return nil
end

local function close()
  local w = explorer_win()
  if w and vim.api.nvim_win_is_valid(w) then
    if #vim.api.nvim_tabpage_list_wins(0) == 1 then
      vim.cmd("enew") -- the explorer was the only window: replace it
    else
      vim.api.nvim_win_close(w, true)
    end
  end
  state.buf, state.win, state.dir = nil, nil, nil
  meta = {}
end

local function get_git_status(path)
  if git_status_cache[path] then
    return git_status_cache[path]
  end
  local uv = vim.uv or vim.loop
  local stat = uv.fs_stat(path)
  if not stat then
    return " "
  end
  -- Check if file is tracked by git
  local cmd = string.format("git -C %s status --porcelain -- %s 2>/dev/null", vim.fn.shellescape(state.dir), vim.fn.shellescape(path))
  local handle = io.popen(cmd)
  if not handle then
    return " "
  end
  local result = handle:read("*a")
  handle:close()
  result = result:gsub("%s+$", "")
  if result == "" then
    git_status_cache[path] = " " -- clean
    return " "
  end
  local status_char = result:sub(1, 1)
  local status_map = {
    ["M"] = "󰏫", -- modified
    ["A"] = "󰐖", -- added
    ["D"] = "󰍵", -- deleted
    ["R"] = "󰁕", -- renamed
    ["C"] = "󰆏", -- copied
    ["U"] = "󰜺", -- unmerged
    ["?"] = "󰈔", -- untracked
    ["!"] = "󰈑", -- ignored
  }
  git_status_cache[path] = status_map[status_char] or "●"
  return git_status_cache[path]
end

local function clear_git_cache()
  git_status_cache = {}
end

local function scandir(dir)
  local uv = vim.uv or vim.loop
  local fd = uv.fs_scandir(dir)
  if not fd then
    return nil
  end
  local entries = {}
  while true do
    local name, t = uv.fs_scandir_next(fd)
    if not name then
      break
    end
    -- Skip .git always, skip hidden files unless show_hidden is true
    if name ~= ".git" and (state.show_hidden or not name:match("^%.")) then
      table.insert(entries, { name = name, is_dir = t == "directory" })
    end
  end
  table.sort(entries, function(a, b)
    if a.is_dir ~= b.is_dir then
      return a.is_dir
    end
    return a.name:lower() < b.name:lower()
  end)
  return entries
end

local function render()
  -- remember the selected node across re-renders (expansion changes lines)
  local sel_path
  local win = explorer_win()
  if win then
    local node = meta[vim.api.nvim_win_get_cursor(win)[1] - 1]
    sel_path = node and node.path or nil
  end

  local hidden_indicator = state.show_hidden and " 󰈈" or ""
  local lines = { ("󰉋 %s/%s"):format(vim.fn.fnamemodify(state.dir, ":~"), hidden_indicator) }
  meta = {}

  local function walk(dir, depth)
    for _, e in ipairs(scandir(dir) or {}) do
      local path = vim.fs.joinpath(dir, e.name)
      local node = {
        name = e.name,
        path = path,
        is_dir = e.is_dir,
        depth = depth,
        parent = dir,
      }
      table.insert(meta, node)
      local git_icon = " "
      if not e.is_dir then
        git_icon = get_git_status(path) .. " "
      end
      local icon = e.is_dir and (expanded[path] and "󰝰" or "󰉋") or icons.for_name(e.name)[1]
      local indent = ("  "):rep(depth)
      table.insert(lines, indent .. icon .. " " .. e.name .. git_icon)
      if e.is_dir and expanded[path] then
        walk(path, depth + 1)
      end
    end
  end
  walk(state.dir, 0)

  local b = state.buf
  vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(b, ns, 0, -1)
  vim.api.nvim_buf_add_highlight(b, ns, "IconCyan", 0, 0, -1) -- header
  for i, node in ipairs(meta) do
    local group = node.is_dir and "IconCyan" or icons.for_name(node.name)[2]
    vim.api.nvim_buf_add_highlight(b, ns, group, i, 0, -1)
    -- Highlight git status icons
    if not node.is_dir then
      local git_icon = get_git_status(node.path)
      if git_icon ~= " " then
        vim.api.nvim_buf_add_highlight(b, ns, "GitSignsChange", i, #lines[i+1] - 2, -1)
      end
    end
  end

  if win then
    local lnum = sel_path
        and (function()
          for i, node in ipairs(meta) do
            if node.path == sel_path then
              return i + 1
            end
          end
          return nil
        end)()
      or nil
    lnum = lnum or math.min(vim.api.nvim_win_get_cursor(win)[1], #lines)
    vim.api.nvim_win_set_cursor(win, { math.max(1, lnum), 1 })
  end
end

local function cursor_node()
  local win = explorer_win()
  if not win then
    return nil
  end
  return meta[vim.api.nvim_win_get_cursor(win)[1] - 1]
end

-- A window to open a file in: reuse an existing editor window, otherwise
-- create one new window to the right of the explorer.
local function editor_target()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if w ~= state.win and vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "" then
      return w
    end
  end
  local target
  vim.api.nvim_win_call(state.win, function()
    vim.cmd("vsplit")
    target = vim.api.nvim_get_current_win()
  end)
  vim.api.nvim_win_set_width(state.win, tree_width())
  return target
end

local function action()
  local node = cursor_node()
  if not node then
    return
  end
  if node.is_dir then
    expanded[node.path] = not expanded[node.path]
    render()
  else
    local target = editor_target()
    local new_path = vim.fs.normalize(node.path)
    -- Open file in target window
    vim.api.nvim_win_call(target, function()
      vim.cmd.edit(vim.fn.fnameescape(new_path))
    end)
    -- Switch to the target window
    vim.api.nvim_set_current_win(target)
    local new_buf = vim.api.nvim_get_current_buf()
    -- Close explorer window explicitly using saved state.win
    local explorer_w = state.win
    if explorer_w and vim.api.nvim_win_is_valid(explorer_w) then
      vim.api.nvim_win_close(explorer_w, true)
    end
    state.buf, state.win, state.dir = nil, nil, nil
    meta = {}
    -- Single-file mode: only keep the newly opened file in tabline
    -- Wipe other listed file buffers (not modified) so tabline shows only 1
    vim.schedule(function()
      for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if b.bufnr ~= new_buf and b.name ~= "" and (b.buftype or "") == "" then
          if vim.fn.isdirectory(b.name) == 0 then
            local ft = vim.bo[b.bufnr].filetype
            if ft ~= "explorer" and not vim.bo[b.bufnr].modified then
              -- Don't delete if it's the alternate buffer with unsaved changes
              pcall(vim.api.nvim_buf_delete, b.bufnr, { force = false })
            end
          else
            pcall(vim.api.nvim_buf_delete, b.bufnr, { force = true })
          end
        end
      end
      -- Also wipe any empty [No Name] buffers
      for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if b.name == "" and b.bufnr ~= new_buf then
          if not vim.bo[b.bufnr].modified then
            pcall(vim.api.nvim_buf_delete, b.bufnr, { force = true })
          end
        end
      end
    end)
  end
end

local function parent_dir()
  state.dir = vim.fs.normalize(vim.fn.fnamemodify(state.dir, ":h"))
  render()
end

-- CRUD ---------------------------------------------------------------------

local function do_create(dir, name)
  local path = vim.fs.joinpath(dir, name)
  if name:sub(-1) == "/" then
    return vim.fn.mkdir(path, "p") == 1
  end
  local f = io.open(path, "w")
  if not f then
    return false
  end
  f:close()
  return true
end

local function create()
  local node = cursor_node()
  local dir = node and (node.is_dir and node.path or node.parent) or state.dir
  local name = vim.fn.input("Create: ", "")
  if name == "" then
    return
  end
  if not do_create(dir, name) then
    vim.notify("Create failed", vim.log.levels.ERROR)
    return
  end
  if node and node.is_dir then
    expanded[node.path] = true -- reveal the new entry
  end
  clear_git_cache()
  render()
end

local function do_rename(node, newname)
  local newpath = vim.fs.joinpath(vim.fs.dirname(node.path), newname)
  if not os.rename(node.path, newpath) then
    return false
  end
  -- carry the expansion state to the renamed path
  if expanded[node.path] then
    expanded[newpath] = true
    expanded[node.path] = nil
  end
  return true
end

local function rename()
  local node = cursor_node()
  if not node then
    return
  end
  local newname = vim.fn.input("Rename to: ", node.name)
  if newname == "" or newname == node.name then
    return
  end
  if not do_rename(node, newname) then
    vim.notify("Rename failed", vim.log.levels.ERROR)
    return
  end
  clear_git_cache()
  render()
end

local function do_delete(node)
  if node.is_dir then
    return vim.fn.delete(node.path, "rf") == 0
  end
  return vim.fn.delete(node.path) == 0
end

local function delete()
  local node = cursor_node()
  if not node then
    return
  end
  if vim.fn.confirm(("Delete '%s'?"):format(node.name), "&Yes\n&No", 2) ~= 1 then
    return
  end
  if not do_delete(node) then
    vim.notify("Delete failed", vim.log.levels.ERROR)
    return
  end
  -- drop expansion state for the removed dir and its children
  local prefix = node.path .. "/"
  for p in pairs(expanded) do
    if p == node.path or p:sub(1, #prefix) == prefix then
      expanded[p] = nil
    end
  end
  clear_git_cache()
  render()
end

local function toggle_hidden()
  state.show_hidden = not state.show_hidden
  clear_git_cache()
  render()
end

-- Setup --------------------------------------------------------------------

local function setup()
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].filetype = "explorer"
  vim.bo[state.buf].modifiable = true
  vim.bo[state.buf].buflisted = false -- never show as a tab
  vim.wo[state.win].number = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].signcolumn = "no"
  vim.wo[state.win].winfixwidth = true
  vim.api.nvim_win_set_width(state.win, tree_width())

  vim.keymap.set("n", "<CR>", action, { buffer = state.buf, desc = "Expand / open" })
  vim.keymap.set("n", "l", action, { buffer = state.buf, desc = "Expand / open" })
  vim.keymap.set("n", "<BS>", parent_dir, { buffer = state.buf, desc = "Parent dir" })
  vim.keymap.set("n", "h", parent_dir, { buffer = state.buf, desc = "Parent dir" })
  vim.keymap.set("n", "a", create, { buffer = state.buf, desc = "Create file/folder" })
  vim.keymap.set("n", "r", rename, { buffer = state.buf, desc = "Rename" })
  vim.keymap.set("n", "d", delete, { buffer = state.buf, desc = "Delete" })
  vim.keymap.set("n", "R", render, { buffer = state.buf, desc = "Refresh" })
  vim.keymap.set("n", "H", toggle_hidden, { buffer = state.buf, desc = "Toggle hidden files" })
  vim.keymap.set("n", "q", close, { buffer = state.buf, desc = "Close" })

  render()
end

-- Put the explorer into `win` (fresh buffer, never shared with other windows).
local function open(win, dir)
  state.win = win
  state.dir = dir
  state.buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(win, state.buf)
  setup()
  -- Clean up any stray empty buffers that would pollute tabline
  vim.schedule(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and buf ~= state.buf and vim.bo[buf].buflisted then
        local name = vim.api.nvim_buf_get_name(buf)
        if name == "" and not vim.bo[buf].modified then
          local ok, lines = pcall(vim.api.nvim_buf_get_lines, buf, 0, 1, false)
          if ok and (#lines == 0 or (#lines == 1 and lines[1] == "")) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
          end
        end
      end
    end
  end)
end

-- `<leader>e`: toggle. Opens the explorer at the far left of the tab.
function M.toggle()
  if explorer_win() then
    close()
    return
  end
  vim.cmd("topleft vsplit")
  open(vim.api.nvim_get_current_win(), vim.fn.getcwd())
end

-- `nvim <dir>`: the explorer takes over the initial window (no split yet).
function M.open_here(dir)
  if explorer_win() then
    return
  end
  local target_dir = dir and vim.fn.isdirectory(dir) == 1 and vim.fs.normalize(dir) or vim.fn.getcwd()
  open(vim.api.nvim_get_current_win(), target_dir)
end

function M.is_open()
  return explorer_win() ~= nil
end

function M.get_dir()
  return state.dir
end

-- Auto-refresh on file system changes
local fs_watch_handle
function M.start_watcher()
  if fs_watch_handle then
    return
  end
  local uv = vim.uv or vim.loop
  fs_watch_handle = uv.new_fs_event()
  fs_watch_handle:start(state.dir, { recursive = true }, function(err, fname, events)
    if err then
      return
    end
    vim.schedule(function()
      clear_git_cache()
      render()
    end)
  end)
end

function M.stop_watcher()
  if fs_watch_handle then
    fs_watch_handle:stop()
    fs_watch_handle = nil
  end
end

return M