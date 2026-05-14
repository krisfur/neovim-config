#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./vscodium/install.sh [--copy|--symlink] [--skip-extensions]

Installs the repo-managed VSCodium config into the user config directory.

Options:
  --copy              Copy files into the VSCodium config directory. This is the default.
  --symlink           Create symlinks into the repo-managed files.
  --skip-extensions   Don't install extensions via the codium CLI.
  -h                  Show this help.
  --help              Show this help.
EOF
}

mode="copy"
install_extensions=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --copy)
      mode="copy"
      shift
      ;;
    --symlink)
      mode="symlink"
      shift
      ;;
    --skip-extensions)
      install_extensions=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="${repo_root}/vscodium"

case "$(uname -s)" in
  Linux)
    config_dir="${HOME}/.config/VSCodium/User"
    ;;
  Darwin)
    config_dir="${HOME}/Library/Application Support/VSCodium/User"
    ;;
  *)
    echo "Unsupported OS: $(uname -s). This installer only supports Linux and macOS." >&2
    exit 1
    ;;
esac

mkdir -p "${config_dir}"

timestamp="$(date +%Y%m%d%H%M%S)"

backup_existing() {
  local target="$1"
  if [[ -e "${target}" || -L "${target}" ]]; then
    local backup="${target}.bak.${timestamp}"
    mv "${target}" "${backup}"
    echo "Backed up ${target} -> ${backup}"
  fi
}

install_one() {
  local name="$1"
  local src="${source_dir}/${name}"
  local dest="${config_dir}/${name}"

  backup_existing "${dest}"

  if [[ "${mode}" == "copy" ]]; then
    cp "${src}" "${dest}"
    echo "Copied ${src} -> ${dest}"
  else
    ln -s "${src}" "${dest}"
    echo "Symlinked ${src} -> ${dest}"
  fi
}

install_one "settings.json"
install_one "keybindings.json"

if [[ "${install_extensions}" -eq 1 ]]; then
  if ! command -v codium >/dev/null 2>&1; then
    echo "Warning: 'codium' CLI not found on PATH. Skipping extension install." >&2
    echo "Install extensions later with: xargs -n1 codium --install-extension < ${source_dir}/extensions.txt" >&2
  else
    echo
    echo "Installing extensions..."
    while IFS= read -r ext || [[ -n "${ext}" ]]; do
      [[ -z "${ext}" || "${ext}" =~ ^# ]] && continue
      codium --install-extension "${ext}" --force
    done < "${source_dir}/extensions.txt"
  fi
fi

echo
echo "Installed VSCodium config into: ${config_dir}"
echo "Install mode: ${mode}"
if [[ "${mode}" == "symlink" ]]; then
  echo "Symlink mode means edits in this repo will be reflected directly in VSCodium's config files."
fi
echo
echo "Next steps:"
echo "1. Launch VSCodium. The Nordfox theme should activate; if not, pick it via Preferences: Color Theme."
echo "2. Ensure external tools are available in PATH: stylua, ruff, swiftformat, typst."
echo "3. For Python projects, select the correct interpreter via the status bar / command palette."
