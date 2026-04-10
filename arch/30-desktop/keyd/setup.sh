#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

install_packages keyd

dotfiles_dir="${BOOTSTRAP_ROOT}/../dotfiles"

sudo mkdir -p /etc/keyd

info "Stowing keyd config..."
sudo stow --dir "$dotfiles_dir" --target / --restow keyd
success "Keyd config stowed"

if ! systemctl is-enabled keyd &>/dev/null; then
    info "Enabling keyd.service..."
    sudo systemctl enable --now keyd
    success "keyd.service enabled"
else
    info "Restarting keyd.service to apply config changes..."
    sudo systemctl restart keyd
    success "keyd.service restarted"
fi
