-- Attractive startup dashboard (alpha-nvim), VSCode-like welcome screen.
-- Shows only when nvim is opened with no file AND nothing was restored by
-- the session (see config.session + the VimEnter trigger below).
local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

local function btn(shortcut, label, action)
  return dashboard.button(shortcut, shortcut .. "  " .. label, action)
end

-- Big NEOVIM banner (uses the accent color via the AlphaHeader group).
dashboard.section.header.val = {
  "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ██╗",
  "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗  ██║",
  "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔██╗ ██║",
  "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╗██║",
  "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚████║",
  "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝  ╚═══╝",
}
dashboard.section.header.opts.hl = "AlphaHeader"

local tb = require("telescope.builtin")
dashboard.section.buttons.val = {
  btn("e",  "Explorer",       "<cmd>lua require('config.explorer').toggle()<CR>"),
  btn("p",  "Find file",      tb.find_files),
  btn("f",  "Find in files",  tb.live_grep),
  btn("r",  "Recent files",   tb.oldfiles),
  btn("g",  "Git status",     tb.git_status),
  btn("t",  "TODO list",      "<cmd>TodoTelescope<CR>"),
  btn("s",  "Restore session","<cmd>lua require('persistence').load()<CR>"),
  btn("c",  "Config",         "<cmd>e ~/.config/nvim/init.lua<CR>"),
  btn("q",  "Quit",           "<cmd>qa<CR>"),
}
dashboard.section.buttons.opts.hl = "AlphaButtons"
dashboard.section.buttons.opts.hl_shortcut = "AlphaShortcut"

local function footer()
  local v = vim.version()
  local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null")
  branch = vim.v.shell_error == 0 and branch:gsub("%s+$", "") or nil
  local date = os.date("%A, %d %B %Y")
  return "neovim " .. v.major .. "." .. v.minor .. "." .. v.patch
    .. (branch and ("  󰊢 " .. branch) or "")
    .. "   " .. date
end
dashboard.section.footer.val = footer
dashboard.section.footer.opts.hl = "AlphaFooter"

dashboard.config.layout = {
  { type = "padding", val = 4 },
  dashboard.section.header,
  { type = "padding", val = 2 },
  dashboard.section.buttons,
  { type = "padding", val = 2 },
  dashboard.section.footer,
}

-- alpha manages its own VimEnter autostart (it skips itself when a file/dir
-- is opened, or when other listed buffers exist). This makes the dashboard
-- the default screen for a bare `nvim`.
alpha.setup(dashboard.opts)
