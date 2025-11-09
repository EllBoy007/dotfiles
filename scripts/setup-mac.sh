#!/usr/bin/env bash

install_homebrew() {
  log "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  log "Homebrew installed. Please ensure brew is available on your PATH if this script reports issues."
}

ensure_xcode_cli() {
  if xcode-select -p >/dev/null 2>&1; then
    log "Xcode Command Line Tools already installed."
    return
  fi

  log "Installing Xcode Command Line Tools..."
  if ! xcode-select --install >/dev/null 2>&1; then
    echo "Failed to trigger Xcode Command Line Tools installer. Install them manually via 'xcode-select --install' and rerun." >&2
    exit 1
  fi

  log "Follow the on-screen prompts to finish installing the Command Line Tools, then rerun this script if it exits early."
  while ! xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
  log "Xcode Command Line Tools installation detected."
}

setup_macos() {
  local brewfile="${DOTFILES_DIR}/scripts/Brewfile"

  ensure_xcode_cli

  if ! command -v brew >/dev/null 2>&1; then
    install_homebrew
  fi

  if [[ ! -f "$brewfile" ]]; then
    echo "Missing Brewfile at ${brewfile}. Cannot install dependencies." >&2
    exit 1
  fi

  log "Installing Homebrew bundle dependencies from ${brewfile}..."
  brew bundle --file "$brewfile"

  if [[ -f "${SCRIPT_DIR}/macos-defaults.sh" ]]; then
    source "${SCRIPT_DIR}/macos-defaults.sh"
    apply_macos_defaults
  fi

  VSCODE_TARGET="${HOME}/Library/Application Support/Code/User/settings.json"
}
