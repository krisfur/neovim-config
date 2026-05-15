#!/usr/bin/env bash

set -euo pipefail

# For each installed VSCodium extension, queries Open VSX's REST /latest
# endpoint and updates to it if strictly newer.
#
# Why: VSCodium's update check uses Open VSX's gallery endpoint
#   /vscode/gallery/{pub}/{name}/latest (configured via product.json
#   `latestUrlTemplate`), which currently serves stale "latest" data — e.g.
#   it returns claude-code 2.1.89 while the REST endpoint /api/{pub}/{name}/latest
#   returns 2.1.142. So VSCodium genuinely thinks everything is up to date.
#
# Why the @version + unpin dance:
#   - Plain `--install-extension name` short-circuits on local state (the CLI
#     does not query the gallery if the extension is already installed).
#   - `--install-extension name@version` fetches the exact version, but
#     VS Code's CLI hardcodes `pinned: true` for versioned installs, which
#     disables auto-update for that extension.
#   - We flip metadata.pinned back to false in extensions.json so auto-update
#     can resume — useful for when Open VSX's gallery endpoint catches up.

EXT_JSON="${HOME}/.vscode-oss/extensions/extensions.json"

codium --list-extensions --show-versions | while IFS='@' read -r ext installed; do
  pub="${ext%%.*}"
  name="${ext#*.}"

  latest=$(curl -fsSL "https://open-vsx.org/api/${pub}/${name}/latest" 2>/dev/null \
           | jq -r '.version // empty')

  if [[ -z "${latest}" ]]; then
    printf 'skip   %-50s not on Open VSX\n' "${ext}"
    continue
  fi

  newer=$(printf '%s\n%s\n' "${installed}" "${latest}" | sort -V | tail -1)
  if [[ "${installed}" == "${latest}" || "${newer}" != "${latest}" ]]; then
    printf 'ok     %-50s %s\n' "${ext}" "${installed}"
    continue
  fi

  printf 'update %-50s %s -> %s\n' "${ext}" "${installed}" "${latest}"
  codium --install-extension "${ext}@${latest}" --force
  tmp=$(mktemp)
  jq --arg id "${ext}" '
    map(if (.identifier.id | ascii_downcase) == ($id | ascii_downcase)
        then .metadata.pinned = false else . end)
  ' "${EXT_JSON}" > "${tmp}" && mv "${tmp}" "${EXT_JSON}"
done
