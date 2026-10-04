#!/bin/bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
code_cli=$(command -v code || true)
if [[ -z "$code_cli" ]]; then
  for app in "$HOME/Applications/Visual Studio Code.app" '/Applications/Visual Studio Code.app'; do
    if [[ -x "$app/Contents/Resources/app/bin/code" ]]; then
      code_cli="$app/Contents/Resources/app/bin/code"
      break
    fi
  done
fi
if [[ -z "$code_cli" ]]; then
  echo 'VS Code CLI not found. Install Visual Studio Code and rerun setup.' >&2
  exit 1
fi

echo 'Installing or updating VS Code extensions…'
while IFS= read -r extension || [[ -n "$extension" ]]; do
  extension="${extension%$'\r'}"
  [[ -z "$extension" || "$extension" == \#* ]] && continue
  "$code_cli" --install-extension "$extension" --force
done < "$repo_dir/vscode/extensions.txt"
