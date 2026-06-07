# Neovim Setup

![screenshot](./nvim.png)

## Dependencies

Requires `neovim >= 0.12.x`

### Arch Linux

```bash
sudo pacman -S --needed neovim nodejs npm tree-sitter-cli
```

Clipboard (pick one):

```bash
# Wayland
sudo pacman -S wl-clipboard

# X11
sudo pacman -S xclip
```

### macOS

```bash
brew install neovim node tree-sitter ripgrep
```

Clipboard works out of the box (uses pbcopy/pbpaste).

## Install the config

```bash
mkdir -p ~/.config/nvim
cp init.lua ~/.config/nvim/
nvim
```

On first launch:

- Plugins install automatically via lazy.nvim
- LSPs install automatically via Mason (uses npm for pyright, typescript-language-server, etc.)
- Treesitter parsers install automatically

## Zed fallback

This repo also includes a repo-managed Zed backup configuration under [`zed/`](./zed/README.md).

Use that setup if you want a practical Vim-friendly fallback editor with similar search, LSP, formatting, and pane-navigation workflows, while keeping this Neovim config as the primary setup.

The Zed workflow is intentionally not a literal Neovim keymap port, Python uses Zed-native tooling, Typst PDF generation is terminal-driven with `typst compile` / `typst watch`, Markdown filepath completion is still a known gap, and long lines are visually soft-wrapped to the editor width by default.

See `zed/README.md` for the actual Zed-native workflow and tradeoffs.

## Helix fallback

This repo also includes a repo-managed Helix configuration under [`helix/`](./helix/README.md).

It is a minimal port that reuses the same language servers and formatters, format-on-save, `Ctrl-h/j/k/l` pane navigation, the `Space` leader pickers, and an approximation of the nordfox theme. Helix ships its own LSP client, fuzzy pickers, and tree-sitter support, so most of the Neovim plugins have no equivalent to install, they are just editor features here.

Install with `./helix/install.sh`. See `helix/README.md` for the external tools to install (Homebrew on macOS, mise on Linux) and what does not map across.

## Keymaps

| Keymap           | Action                         |
| ---------------- | ------------------------------ |
| `<Space>sf`      | Search files                   |
| `<Space>sg`      | Live grep (search text)        |
| `<Space>sw`      | Search word under cursor       |
| `<Space>/`       | Fuzzy search in current buffer |
| `<Space><Space>` | Switch buffers                 |
| `<Space>mp`      | Markdown preview toggle        |
| `<Space>tp`      | Typst preview toggle           |
| `<Space>f`       | Format buffer                  |
| `<Space>th`      | Toggle inlay hints             |
| `gcc`            | Comment out selection          |
| `grd`            | Go to definition               |
| `grr`            | Go to references               |
| `grn`            | Rename symbol                  |
| `gra`            | Code action                    |
