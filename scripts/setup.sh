#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CODEX_VSCODE_EXTENSION="${CODEX_VSCODE_EXTENSION:-openai.chatgpt}"
VSCODE_EXTENSIONS=(
  "$CODEX_VSCODE_EXTENSION"
  "GitHub.vscode-pull-request-github"
)

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "unknown" ;;
  esac
}

log() {
  printf '==> %s\n' "$1"
}

install_vscode_extension() {
  local extension_id="$1"
  if ! command -v code >/dev/null 2>&1; then
    log "VS Code CLI 'code' not found; skipping installation of ${extension_id}. Launch VS Code and run 'Shell Command: Install code command in PATH'."
    return
  fi

  if code --list-extensions 2>/dev/null | grep -qx "$extension_id"; then
    log "VS Code extension ${extension_id} already installed."
    return
  fi

  log "Installing VS Code extension ${extension_id}..."
  if ! code --install-extension "$extension_id" >/dev/null; then
    echo "Failed to install VS Code extension ${extension_id}. Install it manually and re-run if needed." >&2
  fi
}

ensure_link() {
  local source_path="$1"
  local target_path="$2"
  local target_dir
  target_dir="$(dirname "$target_path")"

  mkdir -p "$target_dir"

  if [[ -L "$target_path" ]]; then
    local current_target
    current_target="$(readlink "$target_path")"
    if [[ "$current_target" == "$source_path" ]]; then
      log "Link already in place: $target_path"
      return
    fi
    rm "$target_path"
    log "Removed existing symlink at $target_path"
  elif [[ -e "$target_path" ]]; then
    local backup="${target_path}.bak.$(date +%s)"
    mv "$target_path" "$backup"
    log "Moved existing $target_path to $backup"
  fi

  ln -s "$source_path" "$target_path"
  log "Linked $target_path -> $source_path"
}

OS="$(detect_os)"
if [[ "$OS" == "unknown" ]]; then
  echo "Unsupported OS: $(uname -s)" >&2
  exit 1
fi

case "$OS" in
  macos)
    source "${SCRIPT_DIR}/setup-mac.sh"
    setup_macos
    ;;
  linux)
    source "${SCRIPT_DIR}/setup-linux.sh"
    setup_linux
    ;;
  windows)
    source "${SCRIPT_DIR}/setup-windows.sh"
    setup_windows
    ;;
esac

if [[ -z "${VSCODE_TARGET:-}" ]]; then
  echo "VSCODE_TARGET was not set by the platform setup script." >&2
  exit 1
fi

ensure_link "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"
ensure_link "${DOTFILES_DIR}/.hushlogin" "${HOME}/.hushlogin"
ensure_link "${DOTFILES_DIR}/vscode/settings.json" "$VSCODE_TARGET"

if [[ "$OS" == "macos" || "$OS" == "linux" ]]; then
  for extension in "${VSCODE_EXTENSIONS[@]}"; do
    install_vscode_extension "$extension"
  done
fi

log "Dotfiles setup complete for ${OS}."
