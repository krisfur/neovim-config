# Zed Fallback Setup

This directory contains a repo-managed Zed configuration intended as a practical backup to the Neovim setup in this repository.

![screenshot](./zed-screenshot.png)

![screenshot2](./zed-screenshot-2.png)

## Install

```bash
./zed/install.sh
```

This installs into `~/.config/zed/` on linux or `~/Library/Application Support/Zed/` on macOS.

### Default Install Mode

By default, the installer copies files into your Zed config directory and backs up any existing `settings.json`, `keymap.json`, or `tasks.json` before replacing them.

If you want the files in your Zed config directory to track this repo directly:

```bash
./zed/install.sh --symlink
```

## External Tools

Expected tools on `PATH`:

- `stylua`: Lua formatting
- `swiftformat`: Swift formatting
- `typst`: required for the terminal-based Typst compile/watch workflow

Suggested installs:

### Arch Linux

```bash
sudo pacman -S --needed stylua ruff typst
```

For `swiftformat`, use the package source you normally trust for your machine or skip Swift format-on-save until it is installed.

### macOS

```bash
brew install stylua ruff typst swiftformat
```

## Extensions

The settings auto-install these extensions:

- `nord`: Nord theme base
- `lua`: Lua language support
- `swift`: Swift language support
- `zig`: Zig language support
- `odin`: Odin language support
- `typst`: Typst language support

Why these exist:

- `nord` gets the visual baseline close to the current Nordfox setup
- `lua`, `swift`, `zig`, `odin`, and `typst` cover languages that are not all built into Zed by default

## Suggested Workflow

This fallback intentionally uses Zed's native workflow where it is already good, instead of forcing a Neovim leader system that proved unreliable in practice.

- Long lines are visually soft-wrapped to the editor width by default.
- Soft-wrap note: this is display-only and does not insert hard line breaks into files.
- Pane movement: `ctrl-h/j/k/l` or `ctrl-left/right/up/down`
- Pane movement note: `ctrl-left/right/up/down` also works when the focused pane is a Markdown preview
- Project grep/search: `ctrl-shift-f` on Linux/Windows or `cmd-shift-f` on macOS
- In-file search UI: `ctrl-f`
- In-file search UI controls: `enter` next match, `shift-enter` previous match, `alt-enter` select all matches
- Vim slash search: `/` starts Vim search, `n` jumps to the next match, `N` jumps to the previous match
- Diagnostics list: `space q` in Vim mode, or use native `:clist` / `ctrl-shift-m` / `cmd-shift-m`
- Comment toggling: `gcc` in normal mode and `gc` in visual mode
- LSP navigation/refactors: Zed's built-in Vim bindings such as `gd`, `gA`, `cd`, and `g.`
- Markdown preview: `ctrl-shift-v` opens preview in a side split for Markdown files, and `ctrl-left/right/up/down` moves back out of the focused preview
- Typst one-shot compile in (terminal): `typst compile path/to/file.typ`
- Typst live rebuild (in terminal): `typst watch path/to/file.typ`

## Useful Native Vim Extras

- `g /`: open project-wide search from Vim mode
- `gd`: go to definition
- `gA`: find references
- `cd`: rename symbol
- `g.`: open code actions

## Known gaps

- The supported Typst workflow is terminal-driven `typst compile` / `typst watch`.
- No integrated Typst preview workflow is provided.
- Python uses Zed's built-in `basedpyright` and `ruff`. Environment handling still relies on Zed toolchains and virtualenv detection, not the custom Lua resolver from this Neovim config.
- Custom leader-key workflows were intentionally removed because they proved unreliable in real Zed Vim usage.
