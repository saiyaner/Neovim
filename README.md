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
  - A clipboard provider: `wl-clipboard` (Wayland), `xclip`/`xsel` (X11), or `win32yank` (WSL).

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

### Clipboard

The configuration enables the `unnamedplus` register and automatically selects a
clipboard provider in this order: `wl-copy`/`wl-paste`, `xclip`, `xsel`,
`win32yank.exe`, and `pbcopy`/`pbpaste`. If none is available, Neovim falls back
to OSC52 when the installed Neovim version provides it.

On NixOS, `pkgs.perl5Packages.Clipboard` is a Perl library and is not a Neovim
clipboard provider executable. Add the provider matching your session instead:

```nix
# Wayland (recommended for modern NixOS desktops)
environment.systemPackages = with pkgs; [ wl-clipboard ];

# X11
environment.systemPackages = with pkgs; [ xclip ];
```

With Home Manager, use the same packages under `home.packages`. Apply the NixOS
configuration, open a new shell, and verify that `command -v wl-copy wl-paste`
or `command -v xclip` returns paths.

Install the provider that matches your environment, then restart Neovim:

```bash
# Ubuntu/Debian on Wayland
sudo apt install wl-clipboard

# Ubuntu/Debian on X11
sudo apt install xclip

# Fedora
sudo dnf install wl-clipboard xclip
```

To verify the active provider inside Neovim, run `:checkhealth vim.provider` and
inspect `:echo g:clipboard`. Test with `yy` followed by `Ctrl+Shift+V` in
another application. In WSL, install `win32yank.exe` and ensure it is on `PATH`.

### Updating the configuration

This repository uses git submodules for plugins. Update the config and plugins
together with:

```bash
cd ~/.config/nvim
git pull --recurse-submodules
git submodule update --init --recursive
```

After updating, run `nvim --headless '+checkhealth' '+qa'` and review any errors
before using the config normally. Keep local customizations in a separate commit
so they can be restored cleanly if a future update changes a module.

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
| `Ctrl+Left` / `Ctrl+Right` | Move by word (normal and insert mode) |
| `Ctrl+Up` / `Ctrl+Down` | Scroll half-page (normal and insert mode) |
| `Ctrl+A` / `Ctrl+E` | Line start / line end while inserting |
| `<leader>w` | Save file |
| `<leader>wh/wl/wk/wj` | Resize window left/right/up/down |
| `<leader>tn` / `<leader>tx` | New tab / close tab |
| `Y` | Yank from cursor to end of line |
| Visual `p` | Paste without replacing yank register |

## Structure

```
init.lua                 # entry: requires config/* in order
lua/config/              # all modules (options, keymaps, theme, lsp, completion, ...)
pack/vendor/start/*     # plugins as git submodules
```
