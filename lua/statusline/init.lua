local statusline = require("statusline.statusline")
local tabline = require("statusline.tabline")

return {
  statusline = statusline.statusline,
  winbar = statusline.winbar,
  tabline = tabline.tabline,
  close_buf = tabline.close_buf,
  goto_tab = tabline.goto_tab,
  handle = tabline.handle,
}