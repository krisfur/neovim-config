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
- Treesitter parsers install automatically

Language servers and formatters are **not** installed by the config (no Mason);
install them yourself - see below.

## Language servers and formatters

These must be on `PATH`. Install only the ones for languages you use. Commands
are a starting point - verify per platform.

### macOS (all at once)

Every tool below is a brew formula, so one command covers the lot (`clangd`
comes from `llvm`):

```bash
brew install gopls llvm lua-language-server ols prettier ruff rust-analyzer \
  stylua swiftformat tinymist ty typescript typescript-language-server \
  vscode-langservers-extracted zls
```

### Per-tool reference

| Tool | Languages | Install |
| --- | --- | --- |
| `clangd` | C/C++ | `brew install llvm` · nix: `clang-tools` |
| `gopls` | Go | `go install golang.org/x/tools/gopls@latest` |
| `lua-language-server` | Lua | `brew install lua-language-server` · nix: `lua-language-server` |
| `ols` | Odin | build from source · nix: `ols` |
| `ty` | Python (types) | `uv tool install ty` |
| `ruff` | Python (lint/format) | `uv tool install ruff` · `brew install ruff` |
| `rust-analyzer` | Rust | `rustup component add rust-analyzer` |
| `zls` | Zig | `brew install zls` · nix: `zls` |
| `tinymist` | Typst | `cargo install tinymist` · `brew install tinymist` |
| `vscode-eslint-language-server`, `typescript-language-server` | JS/TS | `npm i -g vscode-langservers-extracted typescript-language-server typescript` |
| `stylua` | Lua (format) | `brew install stylua` · `cargo install stylua` |
| `prettier` | JS/TS/JSON (format) | `npm i -g prettier` |
| `swiftformat` | Swift (format) | `brew install swiftformat` |

`sourcekit-lsp` (Swift) ships with the Xcode/Swift toolchain - no separate install.

## Keymaps

| Keymap           | Action                         |
| ---------------- | ------------------------------ |
| `<Space>sf`      | Search files                   |
| `<Space>sg`      | Live grep (search text)        |
| `<Space>sw`      | Search word under cursor       |
| `<Space>/`       | Fuzzy search in current buffer |
| `<Space><Space>` | Switch buffers                 |
| `<Space>mp`      | Markdown preview toggle        |
| `<Space>f`       | Format buffer                  |
| `<Space>th`      | Toggle inlay hints             |
| `gcc`            | Comment out selection          |
| `grd`            | Go to definition               |
| `grr`            | Go to references               |
| `grn`            | Rename symbol                  |
| `gra`            | Code action                    |
