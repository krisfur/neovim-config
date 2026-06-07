#!/usr/bin/env bash
#
# On-demand markdown preview for Helix (replaces markdown-preview.nvim / mdpls).
# Renders the given markdown file to a dark-themed, self-contained HTML file with
# pandoc and opens it in the default browser. Offline, no live reload (re-run to
# refresh). Bound to Space-m in config.toml.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: md-preview.sh <file.md>" >&2
  exit 1
fi

if ! command -v pandoc >/dev/null 2>&1; then
  echo "md-preview: pandoc not found on PATH (brew install pandoc / mise use -g pandoc)" >&2
  exit 1
fi

file="$1"
# Helix's %{buffer_name} can be ~-prefixed; the shell does not expand a leading
# tilde inside a quoted variable, so do it ourselves.
case "${file}" in
  "~")   file="${HOME}" ;;
  "~/"*) file="${HOME}/${file#"~/"}" ;;
esac

if [[ ! -f "${file}" ]]; then
  echo "md-preview: not a file: ${file} (open the markdown buffer first)" >&2
  exit 1
fi

# Resolve to an absolute path so resource resolution does not depend on the
# directory Helix was launched from. Images in the markdown are relative to the
# file's own directory, so point pandoc's resource-path there.
file_dir="$(cd "$(dirname "${file}")" && pwd)"
file_abs="${file_dir}/$(basename "${file}")"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
css="${script_dir}/markdown-dark.css"
out="${TMPDIR:-/tmp}/hx-md-preview.html"

pandoc "${file_abs}" \
  --from gfm \
  --standalone \
  --embed-resources \
  --resource-path "${file_dir}" \
  --metadata title="$(basename "${file}")" \
  --css "${css}" \
  --output "${out}"

case "$(uname -s)" in
  Darwin)
    open "${out}"
    ;;
  *)
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "${out}" >/dev/null 2>&1 &
    else
      echo "md-preview: rendered to ${out} (no xdg-open found to launch a browser)" >&2
    fi
    ;;
esac
