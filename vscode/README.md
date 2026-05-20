# VS Code Fallback Setup

This directory contains a repo-managed Microsoft VS Code configuration intended as a practical backup to the Neovim setup in this repository. It mirrors the sibling VSCodium fallback, with the differences that Microsoft's build forces on us: the official marketplace, the bundled Copilot / Chat surface, and telemetry-on-by-default.

If you want a clean, non-Microsoft setup, use [`../vscodium`](../vscodium) instead. This directory exists for situations where you need the official build — e.g. for the proprietary `ms-vscode-remote.remote-ssh`, the official Pylance/Python extensions, or anything else that is licensed VS Code Marketplace only.

## Install

Get VS Code from homebrew:

```bash
brew install --cask visual-studio-code
```

```bash
./vscode/install.sh
```

This installs into:

- Linux: `~/.config/Code/User/`
- macOS: `~/Library/Application Support/Code/User/`

### Default install mode

By default, the installer copies `settings.json` and `keybindings.json` into your VS Code user directory and backs up any existing files of the same name. Extensions are installed via the `code` CLI from `extensions.txt`.

To track this repo directly:

```bash
./vscode/install.sh --symlink
```

To skip extension installation:

```bash
./vscode/install.sh --skip-extensions
```

## Disabling Copilot / Chat / telemetry

`settings.json` already sets everything we can switch off via config:

- `chat.disableAIFeatures: true` — Microsoft's official kill-switch that hides chat and inline suggestions. Recent VS Code builds mark `GitHub.copilot-chat` as truly built-in (cannot be uninstalled even with `--force`), so this setting is the supported way to make it go away.
- `telemetry.telemetryLevel: "off"` and related telemetry / experiment flags.
- `github.copilot.enable` set to `false` for every language and `scminput`.
- `github.copilot.editor.enableAutoCompletions: false` and `github.copilot.nextEditSuggestions.enabled: false`.
- `editor.inlineSuggest.enabled: false` to also kill non-Copilot inline ghost text.
- `chat.commandCenter.enabled: false`, `inlineChat.enableV2: false`, and the various `workbench.experimental.*` flags to hide the chat / "next edit" UI as much as VS Code allows.

Recent VS Code builds make `GitHub.copilot-chat` a true built-in extension — it cannot be uninstalled even with `code --uninstall-extension --force`. The `chat.disableAIFeatures` setting above is the only supported way to hide it.

## External tools

Expected tools on `PATH`:

- `stylua`: Lua formatting
- `ruff`: Python formatting / linting
- `swiftformat`: Swift formatting
- `typst`: Typst CLI

### Arch Linux

```bash
sudo pacman -S --needed stylua typst ruff
```

### macOS

```bash
brew install stylua ruff typst swiftformat
```

## Extensions

The installer pulls the following from `extensions.txt`:

- `vscodevim.vim`: Vim motions
- `nuromirg.nightfox-theme-collections`: Nightfox theme collections (provides Nordfox, matches the Neovim setup)
- `sumneko.lua` + `JohnnyMorganz.stylua`: Lua
- `charliermarsh.ruff` + `astral-sh.ty`: Python (ruff for format / lint, ty for type checking)
- `rust-lang.rust-analyzer`: Rust
- `golang.go`: Go
- `swiftlang.swift-vscode`: Swift
- `ziglang.vscode-zig`: Zig
- `DanielGavin.ols`: Odin
- `myriad-dreamin.tinymist`: Typst
- `esbenp.prettier-vscode`: JS / TS / JSON / Markdown formatting
- `Anthropic.claude-code`: Claude Code integration
- `tomoki1207.pdf`: in-editor PDF viewer (useful for Typst output)
- `lucien-martijn.parquet-visualizer`: Parquet / CSV / Avro viewer with paginated tables, schema tab, and DuckDB SQL panel
- `ms-toolsai.jupyter`: Jupyter notebook support
- `ms-vscode-remote.remote-ssh`: official Remote-SSH (proprietary, only works on Microsoft's build)

## Suggested workflow

Vim motions are provided by VSCodeVim. The keybindings layer adds `ctrl-hjkl` for navigating between the sidebar, editor groups, and panel — both inside vim normal/visual modes and in non-editor contexts (sidebar, terminal, etc). `ctrl-arrows` are intentionally not bound on macOS since they collide with Mission Control.

| Shortcut / Command               | Action                                    | Notes                                                  |
| -------------------------------- | ----------------------------------------- | ------------------------------------------------------ |
| `ctrl-h/j/k/l`                   | Navigate between sidebar / editor / panel | Works in normal/visual mode and outside the editor     |
| `cmd-shift-f`                    | Project search / grep                     | Native VS Code multi-file search                       |
| `cmd-f`                          | In-file search UI                         | Use `enter` / `shift-enter` for next / previous result |
| `/`                              | Vim search                                | Use `n` / `N` for next / previous result               |
| `space q`                        | Open Problems panel                       | Mapped via VSCodeVim leader                            |
| `gcc`                            | Toggle comment on current line            | Vim normal mode (VSCodeVim built-in)                   |
| `gc`                             | Toggle comment on selection               | Vim visual mode                                        |
| `gd`                             | Go to definition                          | VSCodeVim built-in                                     |
| `gA`                             | Find references                           | Mapped via VSCodeVim                                   |
| `cd`                             | Rename symbol                             | Mapped via VSCodeVim                                   |
| `g.`                             | Code actions / quick fix                  | Mapped via VSCodeVim                                   |
| `ctrl-shift-v`                   | Open Markdown preview to the side         | Markdown files only                                    |
| `typst compile path/to/file.typ` | One-shot Typst PDF build                  | Run in the integrated terminal or externally           |
| `typst watch path/to/file.typ`   | Continuous Typst rebuild                  | Run in the integrated terminal while editing           |

## Known gaps

- No integrated Typst preview workflow beyond what `tinymist` provides; `typst compile` / `typst watch` from the terminal remains the supported path.
- Python: `ty` is still pre-release; if it misbehaves, disable the extension and fall back to ruff alone.
- Markdown link / image path completion is not configured.
- No `tasks.json` is shipped; use the integrated terminal for build commands.
