-- Git signs in the gutter (like VSCode source control) + hunk navigation.
require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "󰍵" },
    topdelete = { text = "󰍵" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
  signs_staged = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "󰍵" },
    topdelete = { text = "󰍵" },
    changedelete = { text = "▎" },
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "]h", function() gs.next_hunk() end, "Next hunk")
    map("n", "[h", function() gs.prev_hunk() end, "Previous hunk")
    map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
    map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
    map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
    map("n", "<leader>gd", gs.diffthis, "Diff this file")
  end,
})