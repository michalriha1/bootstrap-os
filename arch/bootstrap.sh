#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Arch Linux Bootstrap Script
# Runs setup.sh in each module directory in the order defined below.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BOOTSTRAP_ROOT="$SCRIPT_DIR"
export LOG_DIR="${HOME}/.local/share/bootstrap"
export LOG_FILE="${LOG_DIR}/bootstrap.log"

# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

# Module execution order.
MODULES=(
    00-base/base
    00-base/paru
    10-boot/plymouth
    10-boot/seamless-login
    20-cli/stow
    20-cli/zsh
    20-cli/neovim
    20-cli/fd
    20-cli/zoxide
    30-desktop/hyprland
    30-desktop/keyd
    30-desktop/power
    30-desktop/fonts
    30-desktop/ddcutil
    30-desktop/wireless-regdb
    30-desktop/wezterm
    30-desktop/apps
    40-user/ssh
)

setup_logging() {
    mkdir -p "$LOG_DIR"
    {
        echo "============================================"
        echo "Bootstrap started at $(date)"
        echo "============================================"
    } >> "$LOG_FILE"
}

run_module() {
    local name="$1"
    local module_dir="${SCRIPT_DIR}/${name}"
    local setup="${module_dir}/setup.sh"

    if [[ ! -d "$module_dir" ]]; then
        error "Module '$name' directory not found: $module_dir"
        return 1
    fi
    if [[ ! -f "$setup" ]]; then
        error "Module '$name' has no setup.sh"
        return 1
    fi

    echo ""
    info "=== Module: $name ==="
    MODULE_DIR="$module_dir" bash "$setup"
}

main() {
    echo "============================================"
    echo "  Arch Linux Bootstrap Script"
    echo "============================================"
    echo ""

    setup_logging

    for module in "${MODULES[@]}"; do
        run_module "$module"
    done

    echo ""
    echo "============================================"
    success "Bootstrap complete!"
    echo "============================================"
    info "Log file: $LOG_FILE"

    echo ""
    read -r -p "Reboot now to apply all changes? [y/N] " reply
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        info "Rebooting..."
        sudo systemctl reboot
    else
        info "Skipping reboot. Remember to reboot (or at least re-login) to pick up group/shell/mkinitcpio changes."
    fi
}

main "$@"
