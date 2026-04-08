#!/usr/bin/env bash

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew already installed"
  else
    log "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  brew update
}

install_from_brewfile() {
  if [[ ! -f "$BREWFILE" ]]; then
    warn "Brewfile not found at $BREWFILE, skipping brew bundle"
    return
  fi

  log "Installing formulas/casks from Brewfile"
  brew bundle --file="$BREWFILE"
}

run_homebrew() {
  ensure_homebrew
  install_from_brewfile
}
