#!/usr/bin/env bash

disable_natural_scrolling() {
  log "Disabling natural scrolling..."
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
}

set_dock_size() {
  local size="${1:-43}"
  log "Setting Dock tile size to ${size}..."
  defaults write com.apple.dock tilesize -int "$size"
  killall Dock >/dev/null 2>&1 || true
}

set_dock_zoom() {
  local enabled="${1:-true}"
  local zoom_size="${2:-63}"
  log "Configuring Dock magnification (enabled=${enabled}, size=${zoom_size})..."
  defaults write com.apple.dock magnification -bool "$enabled"
  defaults write com.apple.dock largesize -int "$zoom_size"
  killall Dock >/dev/null 2>&1 || true
}

disable_ds_store_creation() {
  log "Preventing .DS_Store creation on network and USB volumes..."
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  killall Finder >/dev/null 2>&1 || true
}

apply_macos_defaults() {
  disable_natural_scrolling
  set_dock_size 43
  set_dock_zoom true 63
  disable_ds_store_creation
  log "macOS defaults applied. You may need to log out or restart for some changes to take effect."
}
