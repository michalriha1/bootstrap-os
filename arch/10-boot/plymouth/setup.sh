#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

install_packages plymouth

theme_dir="/usr/share/plymouth/themes/arch-custom"
source_dir="${MODULE_DIR}/assets"

backup_path "$theme_dir" sudo

info "Deploying arch-custom plymouth theme..."
sudo mkdir -p "$theme_dir"
sudo cp -r "${source_dir}/." "$theme_dir/"
success "Plymouth theme deployed"

info "Setting arch-custom as default plymouth theme..."
sudo plymouth-set-default-theme arch-custom -R
success "Plymouth theme activated"
