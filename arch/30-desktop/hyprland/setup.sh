#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

install_packages \
    hyprpolkitagent \
    wl-clipboard \
    cliphist \
    wlsunset \
    brightnessctl \
    hypridle

dotfiles_dir="${BOOTSTRAP_ROOT}/../dotfiles"

backup_stow_conflicts "$dotfiles_dir" "$HOME" hypr local-bin

info "Stowing Hyprland config and helper scripts..."
stow --dir "$dotfiles_dir" --target "$HOME" --restow hypr local-bin
chmod +x "${HOME}/.local/bin/os-launch-or-focus"
success "Hyprland config and helper scripts stowed"
