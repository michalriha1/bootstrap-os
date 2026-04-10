#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

if command -v paru &>/dev/null; then
    skip "paru already installed"
    exit 0
fi

info "Installing paru AUR helper..."
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
git clone https://aur.archlinux.org/paru.git "$tmp_dir/paru"
(cd "$tmp_dir/paru" && makepkg -si --noconfirm)
success "paru installed"
