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

| File               | Installed to                          |
| ------------------ | ------------------------------------- |
| `config.toml`      | `~/.config/helix/config.toml`         |
| `languages.toml`   | `~/.config/helix/languages.toml`      |
| `custom.toml`      | `~/.config/helix/themes/custom.toml`  |
| `md-preview.sh`    | `~/.config/helix/md-preview.sh`       |
| `markdown-dark.css`| `~/.config/helix/markdown-dark.css`   |

## Install the config

```bash
./helix/install.sh            # copy (default)
./helix/install.sh --symlink  # symlink to the repo files instead
```

Existing files are backed up to `*.bak.<timestamp>` first. Then run `hx --health`
to see which language servers and formatters Helix can find on your `PATH`.

## External tools

Helix itself plus the language servers and formatters used by `languages.toml`, and
`pandoc` for the markdown preview. Everything is in Homebrew core; `mise` covers most of
the same tools on Linux via its registry, with ecosystem backends for the rest.

### macOS (Homebrew)

```bash
# Editor + language servers / formatters
brew install helix \
  lua-language-server stylua \
  ruff ty \
  rust-analyzer gopls zls ols tinymist marksman \
  llvm \
  swiftformat \
  node uv \
  pandoc          # markdown preview (Space-m)

# Node-based servers and formatter (typescript, eslint, prettier, json)
pnpm install -g typescript typescript-language-server prettier vscode-langservers-extracted
```

`sourcekit-lsp` ships with Xcode / the Swift toolchain on macOS, no separate install.
`clangd` comes from the `llvm` keg; point `language-server.clangd.command` at its full
path (e.g. `/opt/homebrew/opt/llvm/bin/clangd`) if you need to match a system clang.

### Linux (mise)

```bash
# Editor
mise use -g helix

# Language servers / formatters available in the mise registry
mise use -g rust-analyzer gopls zls ruff ty stylua marksman lua-language-server tinymist node pandoc

# Things not in the registry, via mise backends
mise use -g ubi:DanielGavin/ols               # odin language server

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

## Markdown preview

Press `Space m` in a markdown buffer. `md-preview.sh` renders the current file to a
dark-themed, self-contained HTML file with `pandoc` and opens it in your default
browser. It is offline and on-demand: nothing launches automatically, and there is no
live reload, so press `Space m` again to refresh after saving.

The original `mdpls` language server was dropped because Helix can only auto-launch it
(its preview is a `workspace/executeCommand`, which Helix has no way to trigger), and it
themes only code blocks, not the page. The pandoc approach trades live reload for manual
control, full dark mode (`markdown-dark.css`), and no network dependency.

Tweak the styling in `markdown-dark.css`. On Linux the script uses `xdg-open`.

## Python projects

`ty` and `ruff` auto-discover a project `.venv` or honour `VIRTUAL_ENV`. Launch `hx`
from the project root, or use `uv run hx`, so they attach to the right interpreter.

## Keymaps

| Keymap            | Action                                  |
| ----------------- | --------------------------------------- |
| `Ctrl-h/j/k/l`    | Move focus between split views          |
| `{` / `}`         | Jump to prev / next paragraph (extends in select mode) |
| `Space e` / `E`   | File explorer: current file's dir / workspace root (netrw `:Ex`) |
| `Space m`         | Markdown preview in browser (pandoc)    |
| `Space q`         | Diagnostics picker (mirrors `<leader>q`)|
| `Space f`         | File picker (built-in)                  |
| `Space /`         | Project-wide search, regex (= nvim `<Space>sg`); type a pattern, results fill in |
| `/`               | Search within the current buffer, regex; `n`/`N` to step (= nvim `<Space>/`) |
| `Space s` / `S`   | Document / workspace symbol pickers     |
| `Space d` / `D`   | Document / workspace diagnostics        |
| `Space k`         | Hover docs (built-in)                   |
| `g d` / `g r`     | Goto definition / references (built-in) |
| `g a`             | Go to last accessed file (netrw `:Rex`-ish) |

There is no `:Ex` / `:Rex` typed command (Helix has no custom command aliases); the
explorer is on `Space e`, and `Esc` or `g a` takes you back to your file.

Note: in nvim `<Space>/` was a fuzzy search inside the current buffer. Helix has no
fuzzy current-buffer picker, just regex search with `/`. `Space /` is the project-wide
grep (your nvim `<Space>sg`); with an empty prompt it shows `0/0` until you type a
pattern, and the right-hand pane previews the selected match.

See `:tutor` and the [Helix keymap docs](https://docs.helix-editor.com/keymap.html)
for the full default set.
