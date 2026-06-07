# Helix fallback

A minimal port of the Neovim config to [Helix](https://helix-editor.com/).

This is intentionally not a literal keymap port. Helix is modal but selection-first
(verbs come after objects), ships its own LSP client, fuzzy pickers, and tree-sitter
support, and uses a built-in command palette instead of a plugin manager. So the bulk
of the `init.lua` plugins (telescope, blink.cmp, gitsigns, which-key, treesitter,
conform, mason) have no equivalent to install, they are just Helix features configured
in `config.toml` / `languages.toml`.

What carries over: options, the same language servers and formatters, format-on-save,
`Ctrl-h/j/k/l` pane navigation, the `Space` leader pickers, and an approximation of the
nordfox theme with the `#aaffff` accent.

## What does not map

- **Persistent undo** (`undofile`): Helix undo is per-session only.
- **Mason**: Helix does not install language servers for you. Install them yourself (below).
- **Search highlight** (`Search`/`IncSearch`): Helix search jumps and selects rather than
  keeping a persistent highlight, so there is nothing to recolour.
- **Inlay hint toggle**: inlay hints are on by default here instead of behind `<leader>th`.

## Files

| File            | Installed to                          |
| --------------- | ------------------------------------- |
| `config.toml`   | `~/.config/helix/config.toml`         |
| `languages.toml`| `~/.config/helix/languages.toml`      |
| `custom.toml`   | `~/.config/helix/themes/custom.toml`  |

## Install the config

```bash
./helix/install.sh            # copy (default)
./helix/install.sh --symlink  # symlink to the repo files instead
```

Existing files are backed up to `*.bak.<timestamp>` first. Then run `hx --health`
to see which language servers and formatters Helix can find on your `PATH`.

## External tools

Helix itself plus the language servers and formatters used by `languages.toml`.
Everything except `mdpls` (a git-only cargo crate) is in Homebrew core; `mise` covers
most of the same tools on Linux via its registry, with ecosystem backends for the rest.

### macOS (Homebrew)

```bash
# Editor + language servers / formatters
brew install helix \
  lua-language-server stylua \
  ruff ty \
  rust-analyzer gopls zls ols tinymist marksman \
  llvm \
  swiftformat \
  node uv

# Node-based servers and formatter (typescript, eslint, prettier, json)
pnpm install -g typescript typescript-language-server prettier vscode-langservers-extracted

# Optional: markdown browser preview (the markdown-preview.nvim replacement)
# Not published to crates.io, install from the git repo:
cargo install --git https://github.com/euclio/mdpls
```

`sourcekit-lsp` ships with Xcode / the Swift toolchain on macOS, no separate install.
`clangd` comes from the `llvm` keg; point `language-server.clangd.command` at its full
path (e.g. `/opt/homebrew/opt/llvm/bin/clangd`) if you need to match a system clang.

### Linux (mise)

```bash
# Editor
mise use -g helix

# Language servers / formatters available in the mise registry
mise use -g rust-analyzer gopls zls ruff ty stylua marksman lua-language-server tinymist node

# Things not in the registry, via mise backends
mise use -g ubi:DanielGavin/ols               # odin language server

# Optional markdown browser preview (not on crates.io, install from git)
cargo install --git https://github.com/euclio/mdpls

# Node-based servers and formatter
pnpm install -g typescript typescript-language-server prettier vscode-langservers-extracted
```

`clangd` comes from your distro LLVM (`clangd` / `llvm` package). `sourcekit-lsp` and
`swiftformat` are macOS-only here. If a registry name above is missing on your mise
version, run `mise registry | grep <tool>` to find it, or fall back to a backend
(`cargo:`, `go:`, `ubi:`, `npm:`, `pipx:`).

> Tool names and backends shift between releases; treat the lists above as a starting
> point and lean on `hx --health` and `mise registry` to confirm what is actually
> resolvable on your machine.

## Python projects

`ty` and `ruff` auto-discover a project `.venv` or honour `VIRTUAL_ENV`. Launch `hx`
from the project root, or use `uv run hx`, so they attach to the right interpreter.

## Keymaps

| Keymap            | Action                                  |
| ----------------- | --------------------------------------- |
| `Ctrl-h/j/k/l`    | Move focus between split views          |
| `Space q`         | Diagnostics picker (mirrors `<leader>q`)|
| `Space f`         | File picker (built-in)                  |
| `Space /`         | Global search (built-in)                |
| `Space s` / `S`   | Document / workspace symbol pickers     |
| `Space d` / `D`   | Document / workspace diagnostics        |
| `Space k`         | Hover docs (built-in)                   |
| `g d` / `g r`     | Goto definition / references (built-in) |

See `:tutor` and the [Helix keymap docs](https://docs.helix-editor.com/keymap.html)
for the full default set.
