local api = vim.api
local icons = require("config.icons")

local mode_map = {
  n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE",
  ["\22"] = "V-BLOCK", c = "COMMAND", t = "TERMINAL",
  R = "REPLACE", r = "REPLACE", s = "SELECT",
}

local mode_group = {
  n = "StatusModeN", i = "StatusModeI", v = "StatusModeV", V = "StatusModeV",
  ["\22"] = "StatusModeV", c = "StatusModeC", t = "StatusModeT",
  R = "StatusModeR", r = "StatusModeR", s = "StatusModeS",
}

-- git branch is cached per working directory (statusline renders on every move)
local branch_cache = { cwd = nil, branch = nil }

local function git_branch()
  local cwd = vim.fn.getcwd()
  if branch_cache.cwd ~= cwd then
    local out = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null")
    branch_cache.cwd = cwd
    branch_cache.branch = (vim.v.shell_error == 0 and out ~= "")
        and out:gsub("%s+$", "")
      or nil
  end
  return branch_cache.branch
end

local function mode()
  local m = api.nvim_get_mode().mode
  return mode_map[m] or m:upper(), mode_group[m] or "StatusModeN"
end

function M_statusline()
  local m, group = mode()

  local name = api.nvim_buf_get_name(0)
  local modified = vim.bo.modified and " 󰄉" or ""
  local ro = vim.bo.readonly and " 󰌾" or ""
  local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "?"
  local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or "utf-8"

  -- only show a file section when there is a real file (no [No Name])
  local file_part = ""
  if name ~= "" then
    local icon, icong = unpack(icons.get())
    local file = vim.fn.fnamemodify(name, ":t")
    file_part = ("%%#%s# %s %s%s%s"):format(icong, icon, file, modified, ro)
  end

  local lnum, total = vim.fn.line("."), vim.fn.line("$")
  local pct = total > 0 and math.floor(lnum / total * 100) or 0

  local branch = git_branch()
  local branch_str = branch and (" 󰊢 " .. branch) or ""

  local left = ("%%#%s# %s%s"):format(group, m, branch_str)
  local right = ("%%<%%=  %s %%#StatusAccent# %s %%#StatusLine# %s  %d:%d  %d%%%%"):format(
    file_part, ft, enc, lnum, vim.fn.col("."), pct
  )
  return left .. right
end

function M_winbar()
  if vim.bo.filetype == "explorer" then
    return " %#IconCyan# 󰉋 %#WinBar# " .. vim.fn.getcwd()
  end
  local name = api.nvim_buf_get_name(0)
  if name == "" then
    return "" -- no bar for unnamed buffers
  end
  local icon, icong = unpack(icons.get())
  local rel = vim.fn.fnamemodify(name, ":.")
  local modified = vim.bo.modified and " 󰄉" or ""
  return ("%%#%s# %s %%#WinBar# %s%s"):format(icong, icon, rel, modified)
end

return { statusline = M_statusline, winbar = M_winbar }