local api = vim.api
local augroup = api.nvim_create_augroup("UserConfig", { clear = true })

-- Treesitter highlighting: Neovim does not auto-start it for most languages,
-- so start it for every filetype that has a parser installed (parsers live in
-- stdpath("data")/site/parser, queries in stdpath("data")/site/queries).
api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function()
    local lang = vim.bo.filetype
    if lang == "" or lang == "netrw" or lang == "explorer" then
      return
    end
    pcall(vim.treesitter.language.add, lang)
    pcall(vim.treesitter.start, 0)
  end,
})

-- Highlight yanked text briefly
api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Return to last cursor position when reopening a file
api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits on resize
api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    local cur = vim.api.nvim_get_current_win()
    vim.cmd("wincmd =")
    pcall(vim.api.nvim_set_current_win, cur)
  end,
})

-- Terminal buffers: don't number them relatively
api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- Auto-open explorer when nvim starts with a directory argument
-- Also handles `nvim` with no args inside a project: show dashboard (alpha handles it)
api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
    local argv = vim.fn.argv()
    if #argv == 1 and vim.fn.isdirectory(argv[1]) == 1 then
      vim.defer_fn(function()
        -- Clean the directory buffer that Neovim creates for `nvim .`
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= "" and vim.fn.isdirectory(name) == 1 then
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
          end
        end
        local dir = vim.fn.fnamemodify(argv[1], ":p"):gsub("/$", "")
        if vim.fn.isdirectory(dir) == 0 then
          dir = vim.fn.getcwd()
        end
        require("explorer").open_here(dir)
        -- Clean empty [No Name] buffers after explorer opens (deferred)
        vim.defer_fn(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
              local name = vim.api.nvim_buf_get_name(buf)
              if name == "" and not vim.bo[buf].modified then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
            end
          end
        end, 50)
      end, 20)
    end
  end,
})

-- Hide directory buffers from buffer list (so tabline doesn't show them)
api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
  group = augroup,
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name ~= "" and vim.fn.isdirectory(name) == 1 then
      vim.bo[args.buf].buflisted = false
      -- if this is the current buffer and it's a directory, wipe it if explorer not open
      if args.buf == vim.api.nvim_get_current_buf() and not require("explorer").is_open() then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(args.buf) and vim.fn.isdirectory(vim.api.nvim_buf_get_name(args.buf)) == 1 then
            vim.api.nvim_buf_delete(args.buf, { force = true })
          end
        end)
      end
    end
  end,
})

-- LSP keymaps (built into Neovim, no plugins needed)
api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(event)
    local map = function(mode, keys, fn, desc)
      vim.keymap.set(mode, keys, fn, { buffer = event.buf, desc = desc })
    end
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "K", vim.lsp.buf.hover, "Hover documentation")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gr", vim.lsp.buf.references, "Go to references")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>fmt", function()
      vim.lsp.buf.format({ async = true })
    end, "Format buffer")
  end,
})