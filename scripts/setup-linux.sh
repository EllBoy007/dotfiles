#!/usr/bin/env bash

install_base_packages() {
  log "Updating apt indices..."
  sudo apt-get update -y
  log "Installing base packages (curl, wget, gpg, unzip)..."
  sudo apt-get install -y curl wget gpg unzip apt-transport-https ca-certificates lsb-release fontconfig
}

ensure_repo() {
  local list_file="$1"
  local key_cmd="$2"
  local repo_entry="$3"

  sudo mkdir -p /etc/apt/sources.list.d
  if [[ ! -f "$list_file" ]]; then
    eval "$key_cmd"
    echo "$repo_entry" | sudo tee "$list_file" >/dev/null
  fi
}

install_vscode_repo() {
  local arch
  arch="$(dpkg --print-architecture)"
  local keyring="/usr/share/keyrings/microsoft.gpg"
  ensure_repo "/etc/apt/sources.list.d/vscode.list" \
    "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee $keyring >/dev/null" \
    "deb [arch=${arch} signed-by=${keyring}] https://packages.microsoft.com/repos/code stable main"
}

install_gh_repo() {
  local arch
  arch="$(dpkg --print-architecture)"
  local keyring="/usr/share/keyrings/githubcli-archive-keyring.gpg"
  ensure_repo "/etc/apt/sources.list.d/github-cli.list" \
    "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee $keyring >/dev/null && sudo chmod go+r $keyring" \
    "deb [arch=${arch} signed-by=${keyring}] https://cli.github.com/packages stable main"
}

install_github_desktop_repo() {
  local arch
  arch="$(dpkg --print-architecture)"
  local keyring="/usr/share/keyrings/shiftkey-desktop.gpg"
  ensure_repo "/etc/apt/sources.list.d/github-desktop.list" \
    "wget -qO- https://packagecloud.io/shiftkey/desktop/gpgkey | gpg --dearmor | sudo tee $keyring >/dev/null" \
    "deb [arch=${arch} signed-by=${keyring}] https://packagecloud.io/shiftkey/desktop/any/ any main"
}

install_1password_repo() {
  local arch
  arch="$(dpkg --print-architecture)"
  local keyring="/usr/share/keyrings/1password-archive-keyring.gpg"
  if [[ ! -f "$keyring" ]]; then
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor | sudo tee "$keyring" >/dev/null
    sudo chmod go+r "$keyring"
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor | sudo tee /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg >/dev/null
  fi

  ensure_repo "/etc/apt/sources.list.d/1password.list" \
    ":" \
    "deb [arch=${arch} signed-by=${keyring}] https://downloads.1password.com/linux/debian/${arch} stable main"
}

install_chatgpt() {
  if command -v chatgpt >/dev/null 2>&1; then
    log "ChatGPT already installed."
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    sudo apt-get install -y curl
  fi

  log "Fetching latest ChatGPT .deb release..."
  local download_url
  download_url="$(curl -s https://api.github.com/repos/lencx/ChatGPT/releases/latest | grep browser_download_url | grep 'amd64.deb' | head -n1 | cut -d '"' -f4)"
  if [[ -z "$download_url" ]]; then
    echo "Unable to determine ChatGPT release download URL." >&2
    return 1
  fi

  local tmp_deb
  tmp_deb="$(mktemp --suffix=.deb)"
  curl -L "$download_url" -o "$tmp_deb"
  log "Installing ChatGPT from $download_url..."
  sudo dpkg -i "$tmp_deb" || sudo apt-get install -f -y
  rm -f "$tmp_deb"
}

install_font_from_zip() {
  local name="$1"
  local url="$2"
  local font_dir="${HOME}/.local/share/fonts"
  mkdir -p "$font_dir"

  log "Installing font ${name}..."
  local tmpdir
  tmpdir="$(mktemp -d)"
  curl -L "$url" -o "${tmpdir}/font.zip"
  unzip -o "${tmpdir}/font.zip" -d "$tmpdir" >/dev/null
  find "$tmpdir" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp "{}" "$font_dir" \;
  rm -rf "$tmpdir"
}

install_fonts() {
  install_font_from_zip "Caskaydia Cove Nerd Font" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CaskaydiaCove.zip"
  install_font_from_zip "SF Mono Nerd Font Ligaturized" "https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized/archive/refs/heads/main.zip"
  fc-cache -fv "${HOME}/.local/share/fonts" >/dev/null
}

setup_linux() {
  install_base_packages
  install_vscode_repo
  install_gh_repo
  install_github_desktop_repo
  install_1password_repo

  log "Refreshing apt metadata..."
  sudo apt-get update -y
  log "Installing code, gh, github-desktop, and 1password..."
  sudo apt-get install -y code gh github-desktop 1password

  install_chatgpt || echo "ChatGPT installation skipped due to errors."
  install_fonts

  VSCODE_TARGET="${HOME}/.config/Code/User/settings.json"
}
