-- Session persistence (like VSCode reopening your workspace):
--   - bare `nvim` restores the last session automatically
--   - <leader>qs  save session
--   - <leader>ql  load last session
--   - <leader>qd  stop saving (don't save this session)
local persistence = require("persistence")

persistence.setup({
  dir = vim.fn.stdpath("state") .. "/sessions",
  options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
})

-- NOTE: session restore is manual (<leader>ql) on purpose. Auto-loading on
-- startup would leave listed buffers open, which makes the alpha dashboard
-- (whose `should_skip_alpha` skips when other buffers exist) not show. The
-- dashboard is the default startup screen; restore a session from its button
-- or with <leader>ql when you want your workspace back.