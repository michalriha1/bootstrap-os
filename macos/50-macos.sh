#!/usr/bin/env bash

run_macos() {
  if [[ "${APPLY_MACOS_DEFAULTS}" != "true" ]]; then
    warn "Skipping macOS defaults (set APPLY_MACOS_DEFAULTS=true to enable)"
    return
  fi

  if [[ "$(uname)" != "Darwin" ]]; then
    warn "Not on macOS, skipping defaults"
    return
  fi

  log "Applying macOS defaults"

  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true

  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock mru-spaces -bool false

  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  killall Finder Dock SystemUIServer 2>/dev/null || true
}
