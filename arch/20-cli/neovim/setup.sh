#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

install_packages neovim

nvim_config="${HOME}/.config/nvim"

backup_path "$nvim_config"

info "Setting up LazyVim..."
git clone https://github.com/LazyVim/starter "$nvim_config"
rm -rf "${nvim_config}/.git"
success "LazyVim installed"
