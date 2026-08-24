# Neovim

A VSCode-style Neovim config — no plugin manager, fast startup, live kitty-themed UI, AI completion, and a custom file explorer.

## Features

- **VSCode-like UI**: custom tabline, statusline, and a custom file explorer (no plugins) with create/rename/delete and expandable trees.
- **AI completion**: [Codeium](https://codeium.com) ghost text + classic `nvim-cmp` sources (buffer, path, snippets, LSP).
- **Live theme**: colors follow your Kitty terminal, re-applied automatically when you change your wallpaper (with contrast/readability guards).
- **Fuzzy everything**: Telescope (files, grep, git, diagnostics, commands) with `fzf-native` sorting.
- **Navigation/jump**: Flash, multi-cursor (`vim-visual-multi`), illuminated occurrences, marks.
- **Quality of life**: Trouble, LSP diagnostics/actions, Gitsigns, undo tree, autopairs, surround, autotag, comments, colorizer, sessions, alpha dashboard, lazygit, dressing pickers.

## Prerequisites

- Neovim **0.10+** (tested on 0.11).
- A **Kitty** terminal (the theme follows `~/.config/kitty/kitty.conf`; set `$KITTY_CONF` to override).
- `git` (for submodules).
- Optional but recommended:
  - `lazygit` (for `<leader>gg`).
  - `node`/`npm` (for some LSP servers).
  - A language server, e.g. `lua_ls`, installed where `nvim-lspconfig` can find it.
  - `ripgrep` (`rg`) for Telescope live grep.

## Installation

This config uses **no plugin manager** — plugins are tracked as git submodules under
`pack/vendor/start/`. Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/saiyaner/Neovim.git ~/.config/nvim
```

If you already cloned without `--recurse-submodules`, run:

```bash
git -C ~/.config/nvim submodule update --init --recursive
```

### Build the native sorter

`telescope-fzf-native.nvim` needs a compiled binary (gitignored, so it is **not**
included by the submodule). Build it once:

```bash
cd ~/.config/nvim/pack/vendor/start/telescope-fzf-native.nvim && make
```

### Codeium (AI completions)

On first use, Codeium will ask you to log in via a browser; your API key is stored
in `~/.cache/nvim/codeium/config.json` (outside this repo — nothing secret is committed).

### First launch

```bash
nvim        # opens the alpha dashboard on a bare launch
```

## Keymaps (highlights)

| Key | Action |
| --- | --- |
| `<leader>e` | Toggle file explorer |
| `<Space>` | Which-key (all leader maps) |
| `<C-p>` / `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep |
| `<leader>fr` | Project search & replace (grug-far) |
| `gd` / `gr` | Go to definition / references |
| `<leader>ca` | Code action |
| `<leader>cf` | Format |
| `<leader>gg` | Lazygit |
| `<leader>xx` | Trouble (workspace diagnostics) |
| `s` / `S` | Flash jump |
| `<leader>qs` / `<leader>ql` | Save / load session |

## Structure

```
init.lua                 # entry: requires config/* in order
lua/config/              # all modules (options, keymaps, theme, lsp, completion, ...)
pack/vendor/start/*     # plugins as git submodules
```
