#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

install_packages ddcutil

modload_file="/etc/modules-load.d/i2c-dev.conf"
if [[ ! -f "$modload_file" ]]; then
    info "Creating $modload_file..."
    echo "i2c-dev" | sudo tee "$modload_file" >/dev/null
    success "i2c-dev module-load entry created"
else
    skip "$modload_file already exists"
fi

if id -nG "$USER" | tr ' ' '\n' | grep -qx i2c; then
    skip "$USER already in i2c group"
else
    info "Adding $USER to i2c group..."
    sudo usermod -aG i2c "$USER"
    warn "Log out and back in (or reboot) for the i2c group change to take effect"
fi
