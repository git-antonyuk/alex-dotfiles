# Sourced by install.sh. Keep detection separate so it can be tested without
# touching installed software. These functions do not run GitHub CLI commands.

app_exists() {
  [[ -d "/Applications/$1" || -d "$HOME/Applications/$1" ]]
}

skip_formula_if_available() {
  local formula="$1"
  shift
  local executable
  for executable in "$@"; do
    command -v "$executable" >/dev/null 2>&1 || return 0
  done
  HOMEBREW_BUNDLE_BREW_SKIP="${HOMEBREW_BUNDLE_BREW_SKIP:-} $formula"
  echo "Skipping $formula: commands already available."
}

configure_package_skips() {
  skip_formula_if_available git git
  skip_formula_if_available gh gh
  skip_formula_if_available python python3 pip3
  skip_formula_if_available node node npm
  skip_formula_if_available go go
  skip_formula_if_available starship starship
  if command -v rustup >/dev/null 2>&1; then
    skip_formula_if_available rustup rustup
  else
    skip_formula_if_available rustup rustc cargo
  fi

  if app_exists 'Visual Studio Code.app'; then
    HOMEBREW_BUNDLE_CASK_SKIP="${HOMEBREW_BUNDLE_CASK_SKIP:-} visual-studio-code"
    echo 'Skipping Visual Studio Code: app already exists.'
  fi
  if app_exists 'Zed.app'; then
    HOMEBREW_BUNDLE_CASK_SKIP="${HOMEBREW_BUNDLE_CASK_SKIP:-} zed"
    echo 'Skipping Zed: app already exists.'
  fi
  export HOMEBREW_BUNDLE_BREW_SKIP HOMEBREW_BUNDLE_CASK_SKIP
}

install_language_tools() {
  if command -v tsc >/dev/null 2>&1; then
    echo 'Skipping TypeScript: tsc already available.'
  else
    echo 'Installing TypeScript…'
    npm install --global --prefix "$HOME/.local/npm" typescript
  fi

  if command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1 \
      && rustc --version >/dev/null 2>&1 && cargo --version >/dev/null 2>&1; then
    echo 'Skipping Rust: working compiler and Cargo already available.'
  else
    echo 'Installing Rust stable with rustfmt and Clippy…'
    rustup toolchain install stable --profile default --component rustfmt --component clippy
    rustup default stable
  fi
}
