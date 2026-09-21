-- Clipboard provider configuration.
-- Prefer a native system clipboard tool, then fall back to OSC52 for terminals.

local function executable(name)
  return vim.fn.executable(name) == 1
end

local function set_provider(name, copy, paste)
  vim.g.clipboard = {
    name = name,
    copy = copy,
    paste = paste,
    cache_enabled = 0,
  }
end

if executable("wl-copy") and executable("wl-paste") then
  set_provider("wl-clipboard", {
    ["+"] = { "wl-copy", "--foreground" },
    ["*"] = { "wl-copy", "--primary", "--foreground" },
  }, {
    ["+"] = { "wl-paste", "--no-newline" },
    ["*"] = { "wl-paste", "--primary", "--no-newline" },
  })
elseif executable("xclip") then
  set_provider("xclip", {
    ["+"] = { "xclip", "-quiet", "-selection", "clipboard" },
    ["*"] = { "xclip", "-quiet", "-selection", "primary" },
  }, {
    ["+"] = { "xclip", "-o", "-selection", "clipboard" },
    ["*"] = { "xclip", "-o", "-selection", "primary" },
  })
elseif executable("xsel") then
  set_provider("xsel", {
    ["+"] = { "xsel", "--clipboard", "--input" },
    ["*"] = { "xsel", "--primary", "--input" },
  }, {
    ["+"] = { "xsel", "--clipboard", "--output" },
    ["*"] = { "xsel", "--primary", "--output" },
  })
elseif executable("win32yank.exe") then
  set_provider("win32yank", {
    ["+"] = { "win32yank.exe", "-i", "--crlf" },
    ["*"] = { "win32yank.exe", "-i", "--crlf" },
  }, {
    ["+"] = { "win32yank.exe", "-o", "--lf" },
    ["*"] = { "win32yank.exe", "-o", "--lf" },
  })
elseif executable("pbcopy") and executable("pbpaste") then
  set_provider("pbcopy", {
    ["+"] = { "pbcopy" },
    ["*"] = { "pbcopy" },
  }, {
    ["+"] = { "pbpaste" },
    ["*"] = { "pbpaste" },
  })
elseif vim.ui.clipboard and vim.ui.clipboard.osc52 then
  vim.g.clipboard = vim.ui.clipboard.osc52
else
  vim.schedule(function()
    vim.notify(
      "Clipboard provider tidak ditemukan. Tambahkan pkgs.wl-clipboard atau pkgs.xclip ke NixOS.",
      vim.log.levels.WARN
    )
  end)
end

vim.opt.clipboard = "unnamedplus"
