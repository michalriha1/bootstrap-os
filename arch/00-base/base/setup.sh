#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

# This module runs before paru exists, so it uses raw pacman directly
# instead of install_packages.
pkgs=(git base-devel)
to_install=()
for pkg in "${pkgs[@]}"; do
    if is_installed "$pkg"; then
        skip "$pkg already installed"
    else
        to_install+=("$pkg")
    fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
    info "Installing base packages: ${to_install[*]}"
    sudo pacman -S --noconfirm --needed "${to_install[@]}"
    for pkg in "${to_install[@]}"; do
        success "$pkg installed"
    done
fi
