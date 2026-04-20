#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./zed/install.sh [--copy|--symlink]

Installs the repo-managed Zed config into the user config directory.

Options:
  --copy     Copy files into the Zed config directory. This is the default.
  --symlink  Create symlinks into the repo-managed files.
  -h       Show this help.
  --help   Show this help.
EOF
}

mode="copy"

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
source_dir="${repo_root}/zed"

case "$(uname -s)" in
  Linux)
    config_dir="${HOME}/.config/zed"
    ;;
  Darwin)
    config_dir="${HOME}/.config/zed"
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
install_one "keymap.json"
install_one "tasks.json"

echo
echo "Installed Zed config into: ${config_dir}"
echo "Install mode: ${mode}"
if [[ "${mode}" == "symlink" ]]; then
  echo "Symlink mode means edits in this repo will be reflected directly in Zed's config files."
fi
echo
echo "Next steps:"
echo "1. Launch Zed and let auto-install pull the configured extensions."
echo "2. If the Nord theme does not activate automatically, open the theme selector and choose Nord manually."
echo "3. Ensure external tools are available in PATH: stylua, ruff, and swiftformat."
echo "4. For Python projects, select the correct virtualenv/toolchain from Zed's toolchain picker when needed."
