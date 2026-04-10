#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

install_packages wezterm-nightly-bin

wezterm_config="${HOME}/.config/wezterm"

backup_path "$wezterm_config"

info "Setting up Wezterm config..."
git clone https://github.com/michalriha1/wez.git "$wezterm_config"
success "Wezterm config installed"
