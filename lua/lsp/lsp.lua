-- LSP servers already installed on the system (nix): lua-language-server,
-- pyright, rust-analyzer, bash-language-server, ts_ls, eslint.
-- Attached with the native vim.lsp API (no lspconfig). Hover (`K`) shows usage documentation, like
-- VSCode.
local cmp_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_lsp.default_capabilities()

local function setup(name, opts)
  vim.lsp.config(name, vim.tbl_deep_extend("force", { capabilities = capabilities }, opts or {}))
  vim.lsp.enable(name)
end

setup("lua_ls", {
  filetypes = { "lua" },
  cmd = { "lua-language-server" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

setup("pyright", {
  filetypes = { "python" },
  cmd = { "pyright-langserver", "--stdio" },
  settings = { python = { analysis = { autoSearchPaths = true } } },
})

setup("rust_analyzer", {
  filetypes = { "rust" }, cmd = { "rust-analyzer" } })

setup("bashls", {
  filetypes = { "sh", "bash", "zsh" }, cmd = { "bash-language-server", "start" } })

setup("ts_ls", {
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
  cmd = { "typescript-language-server", "--stdio" } })

setup("eslint", {
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "javascript.jsx", "typescript.jsx", "vue" },
  cmd = { "eslint", "--stdin" },
  settings = {
    codeAction = { disableRuleComment = { enable = true }, generateDocs = true },
    -- eslint needs to run on the whole workspace in some scenarios, but not globally
    -- for files with "eslint-disable"
    codeActionOnSave = { enable = false },
    rulesCustomizations = {},
    format = { enable = true },
  },
})

local function with_border(handler)
  return function(err, result, ctx, config)
    config = vim.tbl_deep_extend("force", { border = "rounded" }, config or {})
    handler(err, result, ctx, config)
  end
end

vim.lsp.handlers["textDocument/hover"] = with_border(vim.lsp.handlers.hover)
vim.lsp.handlers["textDocument/signatureHelp"] = with_border(vim.lsp.handlers.signature_help)