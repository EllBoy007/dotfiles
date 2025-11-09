#!/usr/bin/env bash

setup_windows() {
  if [[ -n "${APPDATA:-}" ]]; then
    VSCODE_TARGET="${APPDATA}/Code/User/settings.json"
  else
    VSCODE_TARGET="${HOME}/AppData/Roaming/Code/User/settings.json"
  fi
}
