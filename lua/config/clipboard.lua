-- Select Neovim's built-in clipboard provider based on the active session.
-- Do not select wl-clipboard merely because it is installed: it requires
-- WAYLAND_DISPLAY and must not be used from an X11/TTY session.

local function executable(name)
  return vim.fn.executable(name) == 1
end

local has_wayland = (vim.env.WAYLAND_DISPLAY or "") ~= ""
local has_x11 = (vim.env.DISPLAY or "") ~= ""

if has_wayland and executable("wl-copy") and executable("wl-paste") then
  vim.g.clipboard = "wl-clipboard"
elseif has_x11 and executable("xsel") then
  vim.g.clipboard = "xsel"
elseif has_x11 and executable("xclip") then
  vim.g.clipboard = "xclip"
elseif executable("win32yank.exe") then
  vim.g.clipboard = "win32yank"
elseif executable("pbcopy") and executable("pbpaste") then
  vim.g.clipboard = "pbcopy"
else
  local ok = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    vim.g.clipboard = "osc52"
  else
    vim.schedule(function()
      vim.notify(
        "Clipboard provider tidak ditemukan. Tambahkan pkgs.wl-clipboard atau pkgs.xclip ke NixOS.",
        vim.log.levels.WARN
      )
    end)
  end
end

vim.opt.clipboard = "unnamedplus"
