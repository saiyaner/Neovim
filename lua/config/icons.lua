-- File type / extension icons (Nerd Font) with a color group per icon
local M = {}

local by_ft = {
  lua        = { "󰢱", "IconBlue" },
  vim        = { "", "IconGreen" },
  python     = { "󰌠", "IconYellow" },
  javascript = { "󰌞", "IconYellow" },
  typescript = { "󰛦", "IconBlue" },
  tsx        = { "󰛦", "IconBlue" },
  jsx        = { "󰌞", "IconYellow" },
  json       = { "󰘦", "IconYellow" },
  html       = { "󰼏", "IconOrange" },
  css        = { "󰌜", "IconBlue" },
  scss       = { "󰌜", "IconPurple" },
  markdown   = { "󰍔", "IconBlue" },
  php        = { "", "IconPurple" },
  blade      = { "", "IconOrange" },
  rust       = { "󱘗", "IconOrange" },
  go         = { "󰟓", "IconCyan" },
  sh         = { "󰆍", "IconGreen" },
  bash       = { "󰆍", "IconGreen" },
  zsh        = { "󰆍", "IconGreen" },
  yaml       = { "󰈙", "IconRed" },
  toml       = { "󰈙", "IconRed" },
  c          = { "", "IconBlue" },
  cpp        = { "", "IconBlue" },
  java       = { "󰬷", "IconOrange" },
  nix        = { "󱄅", "IconCyan" },
  sql        = { "󰆼", "IconOrange" },
  git        = { "󰊢", "IconOrange" },
  gitcommit  = { "󰊢", "IconOrange" },
  diff       = { "󰆊", "IconGreen" },
  make       = { "󰏓", "IconYellow" },
  dockerfile = { "󰡨", "IconBlue" },
  conf       = { "󰈙", "IconGray" },
  ini        = { "󰈙", "IconGray" },
  cfg        = { "󰈙", "IconGray" },
  txt        = { "󰈙", "IconGray" },
  text       = { "󰈙", "IconGray" },
  help       = { "󰈙", "IconGray" },
}

local by_ext = {
  lock = { "󰌒", "IconYellow" },
  mdx  = { "󰍔", "IconBlue" },
  svg  = { "󰜡", "IconYellow" },
  png  = { "󰈟", "IconPurple" },
  jpg  = { "󰈟", "IconPurple" },
  jpeg = { "󰈟", "IconPurple" },
  gif  = { "󰈟", "IconPurple" },
  webp = { "󰈟", "IconPurple" },
  zip  = { "󰗄", "IconYellow" },
  tar  = { "󰗄", "IconYellow" },
  gz   = { "󰗄", "IconYellow" },
  pdf  = { "󰈦", "IconRed" },
  mp4  = { "󰎆", "IconPurple" },
  mp3  = { "󰎆", "IconPurple" },
  ttf  = { "󰋽", "IconBlue" },
  otf  = { "󰋽", "IconBlue" },
}

-- Defaults
local DEFAULT = { "󰈙", "IconGray" }
local FOLDER = { "󰉋", "IconCyan" }

-- Resolve an icon by file name (extension based, falls back to filetype detection)
---@return { [1]: string, [2]: string } icon and highlight group
function M.for_name(name)
  local ext = vim.fn.fnamemodify(name, ":e"):lower()
  local icon = by_ext[ext]
  if icon then
    return icon
  end
  local ft = vim.filetype.match({ filename = name })
  return by_ft[ft] or DEFAULT
end

-- Resolve an icon for the current buffer
---@return { [1]: string, [2]: string } icon and highlight group
function M.get()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return FOLDER
  end
  return by_ft[vim.bo.filetype] or M.for_name(name)
end

return M