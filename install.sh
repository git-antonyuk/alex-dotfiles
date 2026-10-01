#!/bin/bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
case "${1:-}" in
  --plan|--help|-h)
    echo 'Setup plan (no changes):'
    cat "$repo_dir/Brewfile"
    echo 'Install global TypeScript in ~/.local/npm only when tsc is missing.'
    echo 'Keep existing Rust; install stable with rustfmt and Clippy if missing.'
    echo 'Back up ~/.zshrc if needed, then link dotfiles/.zshrc.'
    echo 'Existing apps/packages are kept; no brew cleanup or uninstall.'
    echo 'Run: bash install.sh'
    exit 0
    ;;
  "") ;;
  *) echo "Unknown option: $1" >&2; exit 2 ;;
esac
[[ $# -le 1 ]] || { echo 'Too many arguments.' >&2; exit 2; }
[[ "$(uname -s)" == Darwin ]] || { echo 'This setup requires macOS.' >&2; exit 1; }

# Apple may require an interactive Command Line Tools installation first.
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo 'Finish the Apple Command Line Tools installer, then run this script again.'
  exit 1
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
if ! command -v brew >/dev/null 2>&1; then
  installer=$(mktemp)
  trap 'rm -f "$installer"' EXIT
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
  /bin/bash "$installer"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Include user-managed executables before deciding what is missing.
export PATH="$HOME/.local/npm/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
brew_prefix=$(brew --prefix)
if ! command -v rustup >/dev/null 2>&1 && [[ -x "$brew_prefix/opt/rustup/bin/rustup" ]]; then
  export PATH="$brew_prefix/opt/rustup/bin:$PATH"
fi
source "$repo_dir/scripts/packages.sh"
configure_package_skips

echo 'Installing missing Homebrew packages and apps…'
HOMEBREW_BUNDLE_NO_UPGRADE=1 brew bundle --verbose --file="$repo_dir/Brewfile"

# A newly installed Homebrew rustup is keg-only.
if ! command -v rustup >/dev/null 2>&1 && [[ -x "$brew_prefix/opt/rustup/bin/rustup" ]]; then
  export PATH="$brew_prefix/opt/rustup/bin:$PATH"
fi
install_language_tools

echo 'Linking Zsh configuration…'

# Back up an existing file or symlink before linking our Zsh configuration.
target="$HOME/.zshrc"
source_file="$repo_dir/dotfiles/.zshrc"
if [[ ! -L "$target" ]] || [[ "$(readlink "$target")" != "$source_file" ]]; then
  if [[ -e "$target" || -L "$target" ]]; then
    backup_dir=$(mktemp -d "$HOME/.dotfiles-backup.XXXXXX")
    mv "$target" "$backup_dir/.zshrc"
    echo "Previous .zshrc saved to $backup_dir/.zshrc"
  fi
  ln -s "$source_file" "$target"
fi

echo 'Setup complete. Open a new Zsh terminal to load your configuration.'
