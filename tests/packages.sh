#!/bin/bash
# Mock commands and app detection; never install or inspect real software.
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/packages.sh"

available=''
apps=''
calls=''
command() {
  [[ "$1" == -v ]] || return 99
  [[ " $available " == *" $2 "* ]]
}
app_exists() { [[ "|$apps|" == *"|$1|"* ]]; }
npm() { calls="$calls npm:$*;"; }
rustup() { calls="$calls rustup:$*;"; }
rustc() { return "${rust_broken:-0}"; }
cargo() { return "${rust_broken:-0}"; }
assert_contains() { [[ "$1" == *"$2"* ]] || { echo "Missing: $2" >&2; exit 1; }; }

# Preinstalled tools and manually installed apps must all be skipped.
available='git gh python3 pip3 node npm pnpm go starship tsc rustc cargo'
apps='Visual Studio Code.app|Zed.app|Raycast.app|Slack.app|Notion.app|Notion Calendar.app|WhatsApp.app|Telegram.app'
HOMEBREW_BUNDLE_BREW_SKIP='existing-skip'
HOMEBREW_BUNDLE_CASK_SKIP='existing-cask'
configure_package_skips
for name in existing-skip git gh python node pnpm go starship rustup; do
  assert_contains " $HOMEBREW_BUNDLE_BREW_SKIP " " $name "
done
for name in existing-cask visual-studio-code zed raycast slack notion notion-calendar whatsapp telegram; do
  assert_contains " $HOMEBREW_BUNDLE_CASK_SKIP " " $name "
done
install_language_tools
[[ -z "$calls" ]]

# Missing software is not skipped and language installers run.
available=''
apps=''
HOMEBREW_BUNDLE_BREW_SKIP=''
HOMEBREW_BUNDLE_CASK_SKIP=''
configure_package_skips
[[ -z "$HOMEBREW_BUNDLE_BREW_SKIP$HOMEBREW_BUNDLE_CASK_SKIP" ]]
install_language_tools
assert_contains "$calls" 'npm:install --global'
assert_contains "$calls" 'rustup:toolchain install stable'
assert_contains "$calls" 'rustup:default stable'

# Python without pip and Node without npm still need their packages.
available='python3 node'
HOMEBREW_BUNDLE_BREW_SKIP=''
configure_package_skips
[[ -z "$HOMEBREW_BUNDLE_BREW_SKIP" ]]

# Only the detected app is skipped; names with spaces must stay intact.
apps='Notion Calendar.app'
HOMEBREW_BUNDLE_CASK_SKIP=''
configure_package_skips
[[ "$HOMEBREW_BUNDLE_CASK_SKIP" == ' notion-calendar' ]]

# rustup proxies without an installed toolchain must trigger setup.
available='rustup rustc cargo tsc'
rust_broken=1
calls=''
install_language_tools
assert_contains "$calls" 'rustup:toolchain install stable'
echo 'Package skip tests passed.'
