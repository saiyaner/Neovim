-- Custom colorscheme: follows the terminal (kitty), which follows the wallpaper.
-- theme-switch writes the current palette into kitty.conf, so nvim reads it from
-- there and re-applies automatically whenever the file changes (wallpaper switch).
--
-- UI elements (statusline, floats, etc.) follow the terminal: its bg/fg and
-- neutral mixes. The wallpaper "accent" (kitty `cursor` color) becomes the main
-- accent. Only code/syntax highlighting stays on a readable dark-optimized
-- palette so it works regardless of the wallpaper.
--
-- Override the source file with $KITTY_CONF (useful for testing).

local M = {}

local kitty_path = os.getenv("KITTY_CONF") or vim.fn.expand("~/.config/kitty/kitty.conf")

local function hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

local function mix(h1, h2, t)
  local r1, g1, b1 = tonumber(h1:sub(2, 3), 16), tonumber(h1:sub(4, 5), 16), tonumber(h1:sub(6, 7), 16)
  local r2, g2, b2 = tonumber(h2:sub(2, 3), 16), tonumber(h2:sub(4, 5), 16), tonumber(h2:sub(6, 7), 16)
  return hex(
    math.floor(r1 * (1 - t) + r2 * t + 0.5),
    math.floor(g1 * (1 - t) + g2 * t + 0.5),
    math.floor(b1 * (1 - t) + b2 * t + 0.5)
  )
end

-- Syntax palette: dark-optimized, readable on any wallpaper (Tokyo Night inspired).
local function default_c()
  return {
    fg        = "#c0caf5",
    fg_dim    = "#a9b1d6",
    comment   = "#787c99",
    bg_float  = "#1a1b26",
    bg_hl     = "#292e42",
    bg_sel    = "#3d59a1",
    blue      = "#7aa2f7",
    cyan      = "#7dcfff",
    teal      = "#73daca",
    green     = "#9ece6a",
    magenta   = "#bb9af7",
    orange    = "#ff9e64",
    red       = "#f7768e",
    yellow    = "#e0af68",
    white     = "#c0caf5",
  }
end

-- UI neutrals: fallback values (used when kitty.conf can't be read).
local function default_u()
  return {
    fg     = "#cacaca",
    fg_dim = "#9a9a9a",
    dim    = "#7a7a7a",
    bg_hl  = "#161616",
    sel    = "#3a3a3a",
  }
end

local function parse_kitty()
  local f = io.open(kitty_path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  local cols = {}
  for k, v in content:gmatch("(%a[%w_]+)%s+(#%x%x%x%x%x%x)") do
    cols[k:lower()] = v:lower()
  end
  if not (cols.background and cols.foreground) then
    return nil
  end
  return cols
end

local c, u, bg

-- Relative luminance + WCAG contrast ratio (used to keep text readable).
local function luminance(h)
  local function lin(v)
    v = v / 255
    return v <= 0.03928 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
  end
  local r, g, b = tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
end

local function contrast(a, b)
  local l1, l2 = luminance(a), luminance(b)
  if l1 < l2 then
    l1, l2 = l2, l1
  end
  return (l1 + 0.05) / (l2 + 0.05)
end

-- Blend `h` toward `toward` until its luminance reaches `target` (0..1).
-- Integer stepping avoids float drift (0.05*7 != 0.35 exactly).
local function lift(h, toward, target)
  local res = h
  for i = 0, 20 do
    res = mix(h, toward, i * 0.05)
    if luminance(res) >= target then
      return res
    end
  end
  return res
end

-- Blend `h` toward `toward` until its contrast against `base` is >= min_ratio.
local function ensure_contrast(base, h, min_ratio, toward)
  local res = h
  for i = 0, 20 do
    res = mix(h, toward, i * 0.05)
    if contrast(base, res) >= min_ratio then
      return res
    end
  end
  return res
end

-- Dim variant of `fg` on `base` with at least `min_ratio` contrast: returns the
-- dimmest tone (smallest lift from base) that stays readable. Since contrast vs
-- a dark base grows with t, we search upward from the base.
local function dim_to(base, fg, min_ratio)
  for i = 0, 20 do
    local tt = i * 0.05
    if contrast(base, mix(base, fg, tt)) >= min_ratio then
      return mix(base, fg, tt)
    end
  end
  return fg
end

-- Rebuild the palettes from kitty.conf. Returns false when the file is unreadable.
local function build()
  c = default_c()
  u = default_u()
  bg = u.bg_hl
  local kit = parse_kitty()
  if not kit then
    return false
  end

  -- Background: keep the wallpaper's darkest color but never too light,
  -- otherwise nothing on top of it is readable.
  bg = kit.background
  if luminance(bg) > 0.15 then
    bg = lift(bg, "#000000", 0.12)
  end

  -- Foreground: keep the wallpaper's lightest color, but GUARANTEE a bright
  -- readable text (lift dark wallpapers toward white, hue preserved).
  local fg = lift(kit.foreground, "#ffffff", 0.66)

  -- Accent: wallpaper's most saturated color (kitty `cursor`), but must stay
  -- visible on the background.
  local accent = kit.cursor or kit.active_border_color or c.blue
  accent = ensure_contrast(bg, accent, 3.5, "#ffffff")

  u.fg     = fg
  u.fg_dim = dim_to(bg, fg, 4.5)
  u.dim    = dim_to(bg, fg, 2.5)
  u.bg     = bg
  u.bg_hl  = mix(bg, fg, 0.08)
  local sel = kit.selection_background or mix(bg, fg, 0.30)
  u.sel = ensure_contrast(bg, sel, 1.6, fg)

  c.fg      = fg
  c.fg_dim  = u.fg_dim
  c.comment = dim_to(bg, fg, 4.0)
  c.bg_float = mix(bg, fg, 0.05)
  c.bg_hl   = mix(bg, fg, 0.10)
  c.bg_sel  = u.sel
  c.blue    = accent
  c.white   = fg
  return true
end

local function hl(group, val)
  vim.api.nvim_set_hl(0, group, val)
end

local function apply()
  -- Base (UI follows the terminal)
  hl("Normal",     { fg = u.fg, bg = "none" })
  hl("NormalFloat",{ fg = u.fg, bg = u.bg_hl })
  hl("FloatBorder",{ fg = u.dim, bg = u.bg_hl })
  hl("EndOfBuffer",{ fg = "none" })
  hl("CursorLine", { bg = u.bg_hl })
  hl("CursorLineNr", { fg = u.fg, bold = true })
  hl("CursorColumn", { bg = u.bg_hl })
  hl("ColorColumn", { bg = u.bg_hl })
  hl("LineNr",     { fg = u.dim })
  hl("SignColumn", { fg = u.fg_dim, bg = "none" })
  hl("Conceal",    { fg = u.fg_dim })
  hl("Cursor",     { reverse = true })
  hl("lCursor",    { reverse = true })
  hl("MatchParen", { fg = c.orange, bold = true })
  hl("NonText",    { fg = u.dim })
  hl("SpecialKey", { fg = u.dim })
  hl("Whitespace", { fg = u.dim })
  hl("Visual",     { bg = u.sel })
  hl("VisualNOS",  { bg = u.sel })
  hl("Search",     { fg = u.bg, bg = c.orange })
  hl("IncSearch",  { fg = u.bg, bg = c.yellow })
  hl("CurSearch",  { fg = u.bg, bg = c.blue })
  hl("QuickFixLine", { bg = u.bg_hl })
  hl("Substitute", { fg = u.bg, bg = c.red })

  -- Message / statusline (terminal background, neutral text)
  hl("StatusLine",     { fg = u.fg, bg = "none" })
  hl("StatusLineNC",   { fg = u.dim, bg = "none" })
  hl("WinBar",         { fg = u.fg_dim, bg = "none" })
  hl("WinBarNC",       { fg = u.dim, bg = "none" })
  hl("StatusAccent",   { fg = u.fg_dim })

  -- Statusline mode colors: ramp derived from terminal bg/fg (grayscale)
  local mode_names = { "StatusModeN", "StatusModeI", "StatusModeV", "StatusModeC", "StatusModeT", "StatusModeR", "StatusModeS" }
  local mode_bg = {}
  if parse_kitty() then
    for i = 1, 7 do
      mode_bg[i] = mix(bg, u.fg, 0.05 * i)
    end
  else
    for i, shade in ipairs({ "#161616", "#1f1f1f", "#282828", "#313131", "#3a3a3a", "#434343", "#4c4c4c" }) do
      mode_bg[i] = shade
    end
  end
  for i, name in ipairs(mode_names) do
    hl(name, { fg = u.fg, bg = mode_bg[i], bold = true })
  end

  -- Icon colors (used by the statusline/winbar file icons)
  for name, col in pairs({
    IconBlue = c.blue,
    IconGreen = c.green,
    IconYellow = c.yellow,
    IconOrange = c.orange,
    IconRed = c.red,
    IconPurple = c.magenta,
    IconCyan = c.cyan,
    IconGray = c.comment,
  }) do
    hl(name, { fg = col })
  end
  hl("TabLine",        { fg = u.dim, bg = "none" })
  hl("TabLineFill",    { fg = u.fg_dim, bg = "none" })
  hl("TabLineSel",     { fg = u.fg, bg = u.bg_hl, bold = true })
  hl("TabActive",      { fg = u.fg, bg = u.bg_hl, bold = true })
  hl("TabInactive",    { fg = u.dim, bg = "none" })
  hl("TabClose",       { fg = u.fg_dim })
  hl("Title",          { fg = u.fg, bold = true })
  hl("ErrorMsg",       { fg = c.red, bold = true })
  hl("WarningMsg",     { fg = c.yellow })
  hl("MoreMsg",        { fg = c.teal })
  hl("Question",       { fg = c.magenta })
  hl("ModeMsg",        { fg = u.fg_dim })
  hl("MsgSeparator",   { fg = u.dim })

  -- Popup menu
  hl("Pmenu",        { fg = u.fg, bg = u.bg_hl })
  hl("PmenuSel",     { fg = u.fg, bg = u.sel })
  hl("PmenuSbar",    { bg = u.sel })
  hl("PmenuThumb",   { bg = u.dim })

  -- Diff (used by :diffthis etc.)
  hl("DiffAdd",      { fg = c.green })
  hl("DiffChange",   { fg = c.yellow })
  hl("DiffDelete",   { fg = c.red })
  hl("DiffText",     { fg = c.blue })
  hl("diffAdded",    { fg = c.green })
  hl("diffRemoved",  { fg = c.red })
  hl("diffChanged",  { fg = c.yellow })

  -- Diagnostics
  hl("DiagnosticError", { fg = c.red })
  hl("DiagnosticWarn",  { fg = c.yellow })
  hl("DiagnosticInfo",  { fg = c.blue })
  hl("DiagnosticHint",  { fg = c.teal })
  hl("DiagnosticOk",    { fg = c.green })
  hl("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
  hl("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.yellow })
  hl("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.blue })
  hl("DiagnosticUnderlineHint",  { undercurl = true, sp = c.teal })
  hl("DiagnosticFloatingError", { fg = c.red })
  hl("DiagnosticFloatingWarn",  { fg = c.yellow })
  hl("DiagnosticFloatingInfo",  { fg = c.blue })
  hl("DiagnosticFloatingHint",  { fg = c.teal })
  hl("DiagnosticSignError", { fg = c.red })
  hl("DiagnosticSignWarn",  { fg = c.yellow })
  hl("DiagnosticSignInfo",  { fg = c.blue })
  hl("DiagnosticSignHint",  { fg = c.teal })
  hl("DiagnosticVirtualTextError", { fg = c.red })
  hl("DiagnosticVirtualTextWarn",  { fg = c.yellow })
  hl("DiagnosticVirtualTextInfo",  { fg = c.blue })
  hl("DiagnosticVirtualTextHint",  { fg = c.teal })

  -- Classic Vim syntax groups
  hl("Comment",     { fg = c.comment, italic = true })
  hl("Todo",        { fg = c.yellow, bold = true })
  hl("Constant",    { fg = c.orange })
  hl("String",      { fg = c.green })
  hl("Character",   { fg = c.teal })
  hl("Number",      { fg = c.orange })
  hl("Float",       { fg = c.orange })
  hl("Boolean",     { fg = c.orange })
  hl("Identifier",  { fg = c.fg })
  hl("Function",    { fg = c.blue })
  hl("Statement",   { fg = c.magenta })
  hl("Conditional", { fg = c.magenta })
  hl("Repeat",      { fg = c.magenta })
  hl("Label",       { fg = c.blue })
  hl("Operator",    { fg = c.magenta })
  hl("Keyword",     { fg = c.magenta })
  hl("Exception",   { fg = c.red })
  hl("PreProc",     { fg = c.blue })
  hl("Include",     { fg = c.blue })
  hl("Define",      { fg = c.magenta })
  hl("Macro",       { fg = c.magenta })
  hl("PreCondit",   { fg = c.magenta })
  hl("Type",        { fg = c.yellow })
  hl("StorageClass",{ fg = c.yellow })
  hl("Structure",   { fg = c.yellow })
  hl("Typedef",     { fg = c.yellow })
  hl("Special",     { fg = c.teal })
  hl("SpecialChar", { fg = c.orange })
  hl("Tag",         { fg = c.magenta })
  hl("Delimiter",   { fg = c.fg_dim })
  hl("SpecialComment", { fg = c.comment, italic = true })
  hl("Debug",       { fg = c.yellow })
  hl("Underlined",  { fg = c.blue, underline = true })
  hl("Ignore",      { fg = c.comment })
  hl("Error",       { fg = c.red })
  hl("FoldColumn",  { fg = u.dim, bg = "none" })
  hl("Folded",      { fg = u.dim, bg = "none" })
  hl("VertSplit",   { fg = u.bg_hl })
  hl("WinSeparator",{ fg = u.bg_hl })

  -- Spelling
  hl("SpellBad",   { undercurl = true, sp = c.red })
  hl("SpellCap",   { undercurl = true, sp = c.yellow })
  hl("SpellLocal", { undercurl = true, sp = c.teal })
  hl("SpellRare",  { undercurl = true, sp = c.magenta })

  -- LSP extras (neutral UI, colored accents kept for function)
  hl("LspReferenceText",   { bg = u.sel })
  hl("LspReferenceRead",   { bg = u.sel, fg = c.blue })
  hl("LspReferenceWrite",  { bg = u.sel, fg = c.orange })
  hl("LspCodeLens",        { fg = u.dim, italic = true })
  hl("LspInlayHint",       { fg = u.dim })
  hl("LspSignatureActiveParameter", { fg = c.yellow, bold = true })

  -- Which-Key (UI follows the terminal; accents match the syntax palette)
  hl("WhichKey",          { fg = c.blue, bold = true })
  hl("WhichKeyGroup",     { fg = c.teal })
  hl("WhichKeyDesc",      { fg = u.fg })
  hl("WhichKeySeparator", { fg = u.dim })
  hl("WhichKeyFloat",     { bg = u.bg_hl })
  hl("WhichKeyBorder",    { fg = u.dim, bg = u.bg_hl })
  hl("WhichKeyValue",     { fg = c.yellow })

  -- Telescope (UI neutral, icons colored)
  hl("TelescopePromptPrefix",  { fg = c.blue })
  hl("TelescopePromptTitle",   { fg = u.fg, bg = u.sel })
  hl("TelescopeResultsTitle",  { fg = u.fg, bg = u.sel })
  hl("TelescopePreviewTitle",  { fg = u.fg, bg = u.sel })
  hl("TelescopeSelection",     { fg = u.fg, bg = u.sel })
  hl("TelescopeSelectionCaret",{ fg = c.blue })
  hl("TelescopeBorder",        { fg = u.dim, bg = u.bg_hl })
  hl("TelescopePromptBorder",  { fg = u.dim, bg = u.bg_hl })
  hl("TelescopeResultsBorder", { fg = u.dim, bg = u.bg_hl })
  hl("TelescopePreviewBorder", { fg = u.dim, bg = u.bg_hl })
  hl("TelescopePromptNormal",  { bg = u.bg_hl })
  hl("TelescopePromptCounter", { fg = u.dim })

  -- Git signs (like VSCode source control colors)
  hl("GitSignsAdd",          { fg = c.green })
  hl("GitSignsChange",       { fg = c.yellow })
  hl("GitSignsDelete",       { fg = c.red })
  hl("GitSignsAddLn",        { fg = c.green })
  hl("GitSignsChangeLn",     { fg = c.yellow })
  hl("GitSignsDeleteLn",     { fg = c.red })
  hl("GitSignsAddNr",        { fg = c.green })
  hl("GitSignsChangeNr",     { fg = c.yellow })
  hl("GitSignsDeleteNr",     { fg = c.red })
  hl("GitSignsUntracked",    { fg = c.green })

  -- Indent guides (subtle, terminal-following)
  hl("IblIndent", { fg = u.bg_hl })
  hl("IblScope",  { fg = u.dim })

  -- Bookmarks (marks.nvim) — accent colored so they stand out from line numbers
  hl("MarksAddMark",   { fg = c.blue, bold = true })
  hl("MarksHlLine",    { bg = u.bg_hl })
  hl("MarksSignHL",    { fg = c.blue, bold = true })
  hl("MarksSignAddHL", { fg = c.blue, bold = true })

  -- TODO comments (VSCode TODO tree colors)
  hl("TodoBgFix",  { fg = u.bg, bg = c.red })
  hl("TodoBgTodo", { fg = u.bg, bg = c.blue })
  hl("TodoBgHack", { fg = u.bg, bg = c.orange })
  hl("TodoBgWarn", { fg = u.bg, bg = c.yellow })
  hl("TodoBgPerf", { fg = u.bg, bg = c.magenta })
  hl("TodoBgNote", { fg = u.bg, bg = c.teal })
  hl("TodoFix",  { fg = c.red })
  hl("TodoTodo", { fg = c.blue })
  hl("TodoHack", { fg = c.orange })
  hl("TodoWarn", { fg = c.yellow })
  hl("TodoPerf", { fg = c.magenta })
  hl("TodoNote", { fg = c.teal })

  -- Completion menu icons (own them so they follow the accent too)
  local kind_colors = {
    Text = c.fg_dim, Method = c.blue, Function = c.blue, Constructor = c.blue,
    Field = c.yellow, Variable = c.yellow, Class = c.orange, Interface = c.orange,
    Module = c.blue, Property = c.yellow, Unit = c.blue, Value = c.yellow,
    Enum = c.orange, Keyword = c.magenta, Snippet = c.green, Color = c.green,
    File = c.green, Reference = c.blue, Folder = c.blue, EnumMember = c.orange,
    Constant = c.yellow, Struct = c.orange, Event = c.orange, Operator = c.blue,
    TypeParameter = c.blue, Codeium = c.blue,
  }
  for kind, col in pairs(kind_colors) do
    hl("CmpItemKind" .. kind, { fg = col })
  end

  -- Word occurrences under cursor (illuminate) — subtle, VSCode-like
  hl("IlluminateWord",   { bg = u.bg_hl })
  hl("IlluminateCurWord",{ bg = u.sel })

  -- Undo tree (undotree)
  hl("UndotreeNode",    { fg = u.dim })
  hl("UndotreeNodeCurrent", { fg = c.blue, bold = true })
  hl("UndotreeCurrent", { fg = c.blue, bold = true })
  hl("UndotreeSavedSmall", { fg = c.yellow })
  hl("UndotreeSavedBig",   { fg = c.yellow, bold = true })
  hl("UndotreeNext",    { fg = c.green })
  hl("UndotreePrev",    { fg = c.red })
  hl("UndotreeSeq",     { fg = u.dim })
  hl("UndotreeTimeStamp", { fg = c.cyan })
  hl("UndotreeBranch",  { fg = u.dim })
  hl("UndotreeFirstNode", { fg = c.teal })
  hl("UndotreeHead",    { fg = c.blue })
  hl("UndotreeHelp",    { fg = u.dim })
  hl("UndotreeHelpKey", { fg = c.blue })
  hl("UndotreeHelpTitle", { fg = c.yellow })

  -- Grug-far: replace the hardcoded indicators with the palette
  hl("GrugFarResultsChangeIndicator", { fg = c.red })
  hl("GrugFarResultsRemoveIndicator", { fg = c.red })
  hl("GrugFarResultsAddIndicator",    { fg = c.green })
  hl("GrugFarCurrentMatch",           { bg = u.sel, fg = u.fg })

  -- Multi-cursor (vim-visual-multi)
  hl("VM_Mono",   { bg = u.sel, fg = u.fg })
  hl("VM_Extend", { bg = u.sel, fg = u.fg })
  hl("VM_Visual", { bg = u.sel })
  hl("VM_Cursor", { reverse = true })
  hl("VM_Insert", { reverse = true })

  -- Flash (jump labels)
  hl("FlashLabel",   { fg = u.bg, bg = c.blue, bold = true })
  hl("FlashMatch",   { bg = u.sel, fg = u.fg })
  hl("FlashCurrent", { fg = c.blue, underline = true })
  hl("FlashBackdrop", { fg = u.dim })

  -- Dashboard (alpha-nvim)
  hl("AlphaHeader",  { fg = c.blue, bold = true })
  hl("AlphaHeader2", { fg = c.orange, bold = true })
  hl("AlphaButtons", { fg = u.fg })
  hl("AlphaShortcut",{ fg = c.blue, bold = true })
  hl("AlphaFooter",  { fg = u.dim, italic = true })

  -- Treesitter captures
  local ts = {
    ["@comment"]              = { fg = c.comment, italic = true },
    ["@comment.error"]        = { fg = c.red, italic = true },
    ["@comment.warning"]      = { fg = c.yellow, italic = true },
    ["@comment.todo"]         = { fg = c.yellow, bold = true },
    ["@comment.documentation"]= { fg = c.comment, italic = true },
    ["@constant"]             = { fg = c.orange },
    ["@constant.builtin"]     = { fg = c.orange, bold = true },
    ["@constant.macro"]       = { fg = c.orange, bold = true },
    ["@string"]               = { fg = c.green },
    ["@string.regexp"]        = { fg = c.teal },
    ["@string.escape"]        = { fg = c.yellow },
    ["@string.special"]       = { fg = c.teal },
    ["@character"]            = { fg = c.teal },
    ["@number"]               = { fg = c.orange },
    ["@number.float"]         = { fg = c.orange },
    ["@boolean"]              = { fg = c.orange },
    ["@variable"]             = { fg = c.fg },
    ["@variable.builtin"]     = { fg = c.red },
    ["@variable.parameter"]   = { fg = c.fg_dim },
    ["@variable.member"]      = { fg = c.fg },
    ["@property"]             = { fg = c.cyan },
    ["@field"]                = { fg = c.cyan },
    ["@function"]             = { fg = c.blue },
    ["@function.builtin"]     = { fg = c.blue, bold = true },
    ["@function.call"]        = { fg = c.blue },
    ["@function.macro"]       = { fg = c.magenta },
    ["@method"]               = { fg = c.blue },
    ["@method.call"]          = { fg = c.blue },
    ["@constructor"]          = { fg = c.orange },
    ["@conditional"]          = { fg = c.magenta },
    ["@repeat"]               = { fg = c.magenta },
    ["@label"]                = { fg = c.blue },
    ["@operator"]             = { fg = c.magenta },
    ["@keyword"]              = { fg = c.magenta },
    ["@keyword.function"]     = { fg = c.red },
    ["@keyword.return"]       = { fg = c.red },
    ["@keyword.operator"]     = { fg = c.magenta },
    ["@keyword.directive"]    = { fg = c.magenta, bold = true }, -- blade @foreach, @if, ...
    ["@keyword.directive.end"]= { fg = c.magenta },
    ["@exception"]            = { fg = c.red },
    ["@include"]              = { fg = c.blue },
    ["@type"]                 = { fg = c.yellow },
    ["@type.builtin"]         = { fg = c.yellow, bold = true },
    ["@type.qualifier"]       = { fg = c.yellow },
    ["@type.definition"]      = { fg = c.yellow },
    ["@namespace"]            = { fg = c.yellow },
    ["@module"]               = { fg = c.yellow },
    ["@storageclass"]         = { fg = c.yellow },
    ["@attribute"]            = { fg = c.teal },
    ["@decorator"]            = { fg = c.teal },
    ["@punctuation.delimiter"]= { fg = c.fg_dim },
    ["@punctuation.bracket"]  = { fg = c.fg_dim },
    ["@punctuation.special"]  = { fg = c.orange },
    ["@tag"]                  = { fg = c.red },
    ["@tag.attribute"]        = { fg = c.teal },
    ["@tag.delimiter"]        = { fg = c.fg_dim },
    ["@tag.builtin"]          = { fg = c.red },
    ["@error"]                = { fg = c.red },
    ["@markup.heading"]       = { fg = c.blue, bold = true },
    ["@markup.strong"]        = { bold = true },
    ["@markup.italic"]        = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.link"]          = { fg = c.blue, underline = true },
    ["@markup.link.label"]    = { fg = c.cyan },
    ["@markup.link.url"]      = { fg = c.blue, underline = true },
    ["@markup.raw"]           = { fg = c.green },
    ["@markup.list"]          = { fg = c.magenta },
    ["@markup.quote"]         = { fg = c.magenta },
    ["@markup.underline"]     = { underline = true },
    ["@markup.code"]          = { fg = c.teal },
    ["@diff.plus"]            = { fg = c.green },
    ["@diff.minus"]           = { fg = c.red },
    ["@diff.delta"]           = { fg = c.yellow },
    ["@diff.unchanged"]       = { fg = c.comment },
  }
  for group, val in pairs(ts) do
    hl(group, val)
  end

  vim.opt.background = "dark"
end

-- Re-apply the theme. Call this after build() to push changes to the screen.
function M.apply()
  apply()
end

-- Rebuild palettes from kitty.conf and re-apply. Returns false when unreadable.
function M.refresh()
  local ok = build()
  M.u = u
  M.c = c
  M.bg = bg
  if ok then
    apply()
  end
  return ok
end

-- Watch kitty.conf (or $KITTY_CONF) for changes: when the wallpaper theme-switch
-- rewrites it, nvim rebuilds and re-applies the colors automatically.
local watch_handle
local debounce

local function schedule_reload()
  if debounce then
    debounce:stop()
    debounce:close()
    debounce = nil
  end
  debounce = vim.uv.new_timer()
  debounce:start(400, 0, vim.schedule_wrap(function()
    M.refresh()
  end))
end

local function start_watch()
  local dir = kitty_path:match("^(.*)/[^/]+$") or "."
  watch_handle = vim.uv.new_fs_event()
  watch_handle:start(dir, {}, function(err, fname)
    if err then
      return
    end
    schedule_reload()
  end)
end

build()
apply()
M.u = u
M.c = c
M.bg = bg
start_watch()

return M