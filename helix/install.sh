#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./helix/install.sh [--copy|--symlink]

Installs the repo-managed Helix config into the user config directory.

Options:
  --copy     Copy files into the Helix config directory. This is the default.
  --symlink  Create symlinks into the repo-managed files.
  -h         Show this help.
  --help     Show this help.

This installer only copies config files. See helix/README.md for the external
tools (language servers and formatters) you need to install separately.
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
source_dir="${repo_root}/helix"

case "$(uname -s)" in
  Linux)
    config_dir="${HOME}/.config/helix"
    ;;
  Darwin)
    config_dir="${HOME}/.config/helix"
    ;;
  *)
    echo "Unsupported OS: $(uname -s). This installer only supports Linux and macOS." >&2
    exit 1
    ;;
esac

mkdir -p "${config_dir}/themes"

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
  local dest_rel="${2:-$1}"
  local src="${source_dir}/${name}"
  local dest="${config_dir}/${dest_rel}"

  backup_existing "${dest}"

  if [[ "${mode}" == "copy" ]]; then
    cp "${src}" "${dest}"
    echo "Copied ${src} -> ${dest}"
  else
    ln -s "${src}" "${dest}"
    echo "Symlinked ${src} -> ${dest}"
  fi
}

install_one "config.toml"
install_one "languages.toml"
# config.toml sets `theme = "custom"`, which Helix loads from themes/custom.toml.
install_one "custom.toml" "themes/custom.toml"

echo
echo "Installed Helix config into: ${config_dir}"
echo "Install mode: ${mode}"
if [[ "${mode}" == "symlink" ]]; then
  echo "Symlink mode means edits in this repo will be reflected directly in Helix's config files."
fi
echo
echo "Next steps:"
echo "1. Install the external language servers and formatters (see helix/README.md)."
echo "2. Run 'hx --health' to check which tools Helix can find on your PATH."
echo "3. Launch 'hx' from a project root so language servers discover the right project/venv."
