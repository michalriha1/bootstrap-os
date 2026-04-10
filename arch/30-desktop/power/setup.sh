#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

install_packages power-profiles-daemon

if ! systemctl is-enabled power-profiles-daemon &>/dev/null; then
    info "Enabling power-profiles-daemon.service..."
    sudo systemctl enable --now power-profiles-daemon
    success "power-profiles-daemon.service enabled"
else
    skip "power-profiles-daemon.service already enabled"
fi
