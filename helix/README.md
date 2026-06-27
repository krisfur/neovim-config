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

## Coming from Vim

This config deliberately keeps Helix's native paradigm instead of rebinding keys to
imitate Vim. Learning the model is less work than fighting it, and the model is small.

**The core loop is object-then-verb.** A motion *selects* the text it moves over, and the
visible selection is the operand the next key acts on. Vim's `dw` (verb-then-object) is
Helix's `wd` (object-then-verb): same two keys, no mode switch. The persistent highlight
is not a mode to escape - it's Helix showing you what the next verb will hit. The next
motion just replaces it. You do **not** press `v` first; select mode is only for *gluing
several motions into one larger selection* before acting (irregular ranges, sticky
extends), which is rare in everyday editing.

| Vim                       | Helix                  | Notes                                       |
| ------------------------- | ---------------------- | ------------------------------------------- |
| `dw` / `cw` / `yw`        | `w` then `d` / `c` / `y` | select first, then the verb               |
| `dd` / `cc` / `yy`        | `x` then `d` / `c` / `y` | `x` selects the whole line                 |
| `de` / `d$`               | `e` then `d` / `gl` then `d` | `gl` = goto line end                   |
| `viw` / `vaw`             | `mi w` / `ma w`        | text objects live under match mode `m`      |
| `vi(` / `va(`             | `mi (` / `ma (`        | also `mi {`, `mi "`, `mi p` (paragraph)     |
| `ci(` / `di"`             | `mi (` then `c` / `mi "` then `d` | select the object, then the verb |
| `%`                       | `mm`                   | jump to matching bracket                    |
| `ysiw)` (surround add)    | `mi w` then `ms )`     | `ms`/`md`/`mr` = surround add/delete/replace|
| `*` (search word)         | `*` then `n`           | `*` searches the current selection          |
| `{` / `}`                 | `[p` / `]p`            | selects the paragraph it jumps over         |
| `:%s/foo/bar/g`           | `%` `s` `foo<ret>` `c` | select all, split on regex, change each     |
| `Ctrl-v` (block) + edit   | `C` / `Ctrl-c`         | add cursor below; multi-cursor is native    |

Two things that surprise Vim users specifically:

- **`hx .` opens the fuzzy file picker, not a directory listing.** That picker is a flat,
  recursive, gitignore-filtered finder, so it has no `../`. The browsable explorer with
  `../` is `Space e` (`file_explorer`).
- **There's no `:Ex` / `:Rex`.** Helix has no custom command aliases. Use `Space e` to
  explore and `Esc` or `g a` (go to last accessed file) to jump back.

Run `:tutor` once - it's the fastest way to make the loop click.

## Keymaps

Only three things here are added on top of stock Helix - `Ctrl-h/j/k/l` view nav,
the file explorer on `Space e`/`E`, and markdown preview on `Space m`. Everything
else in this table is a Helix default, listed so the Vim muscle memory has a target.

| Keymap            | Action                                  |
| ----------------- | --------------------------------------- |
| `Ctrl-h/j/k/l`    | Move focus between split views (added)  |
| `Space e` / `E`   | File explorer: current file's dir / workspace root (added) |
| `Space m`         | Markdown preview in browser (pandoc, added) |
| `[p` / `]p`       | Jump to prev / next paragraph (selects it) |
| `Space f`         | File picker (built-in)                  |
| `Space /`         | Project-wide search, regex (= nvim `<Space>sg`); type a pattern, results fill in |
| `/`               | Search within the current buffer, regex; `n`/`N` to step (= nvim `<Space>/`) |
| `Space s` / `S`   | Document / workspace symbol pickers     |
| `Space d` / `D`   | Document / workspace diagnostics        |
| `Space k`         | Hover docs (built-in)                   |
| `g d` / `g r`     | Goto definition / references (built-in) |
| `g a`             | Go to last accessed file (netrw `:Rex`-ish) |

Note: in nvim `<Space>/` was a fuzzy search inside the current buffer. Helix has no
fuzzy current-buffer picker, just regex search with `/`. `Space /` is the project-wide
grep (your nvim `<Space>sg`); with an empty prompt it shows `0/0` until you type a
pattern, and the right-hand pane previews the selected match.

See `:tutor` and the [Helix keymap docs](https://docs.helix-editor.com/keymap.html)
for the full default set.
