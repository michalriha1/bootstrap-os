#!/usr/bin/env bash
# Shared helpers for bootstrap modules.
# Sourced by bootstrap.sh and each module's setup.sh.

set -euo pipefail

LOG_DIR="${LOG_DIR:-${HOME}/.local/share/bootstrap}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/bootstrap.log}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_to_file() {
    mkdir -p "$LOG_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

info()    { echo -e "${BLUE}[INFO]${NC} $*";    log_to_file "[INFO] $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*";  log_to_file "[WARN] $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*";    log_to_file "[ERROR] $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*";     log_to_file "[OK] $*"; }
skip()    { echo -e "${YELLOW}[SKIP]${NC} $*";  log_to_file "[SKIP] $*"; }

is_installed() {
    pacman -Q "$1" &>/dev/null
}

BACKUP_KEEP="${BACKUP_KEEP:-10}"

# Rotate backups: <path>.bak -> .bak.1 -> .bak.2 ... up to BACKUP_KEEP.
# The oldest slot (BACKUP_KEEP) is discarded. Copies the current path
# into <path>.bak as the newest snapshot (does NOT move, so the live
# resource stays in place for the caller to replace).
_rotate_backups() {
    local path="$1"
    local use_sudo="$2"
    local sh=""
    [[ "$use_sudo" == "sudo" ]] && sh="sudo "

    local oldest="${path}.bak.${BACKUP_KEEP}"
    eval "${sh}rm -rf \"\$oldest\""

    local i
    for (( i = BACKUP_KEEP - 1; i >= 1; i-- )); do
        local src="${path}.bak.${i}"
        local dst="${path}.bak.$((i + 1))"
        if eval "${sh}test -e \"\$src\" -o -L \"\$src\""; then
            eval "${sh}mv \"\$src\" \"\$dst\""
        fi
    done

    if eval "${sh}test -e \"${path}.bak\" -o -L \"${path}.bak\""; then
        eval "${sh}mv \"${path}.bak\" \"${path}.bak.1\""
    fi
}

backup_path() {
    local path="$1"
    local use_sudo="${2:-}"
    [[ -e "$path" || -L "$path" ]] || return 0
    _rotate_backups "$path" "$use_sudo"
    local bak="${path}.bak"
    info "Backing up $path -> $bak (keeping $BACKUP_KEEP)"
    if [[ "$use_sudo" == "sudo" ]]; then
        sudo mv "$path" "$bak"
    else
        mv "$path" "$bak"
    fi
}

# File-level backup that leaves the original in place (for append-style
# edits like .bashrc). Rotates .bak.N slots the same way.
backup_file_copy() {
    local path="$1"
    [[ -f "$path" ]] || return 0
    _rotate_backups "$path" ""
    cp "$path" "${path}.bak"
    info "Backed up $path -> ${path}.bak (keeping $BACKUP_KEEP)"
}

# Installs packages via paru. Assumes paru is already installed
# (the `paru` module runs early in bootstrap.sh). The `base` module
# installs its prerequisites with raw `sudo pacman` directly, because
# it runs before paru exists.
install_packages() {
    local packages=("$@")
    local to_install=()

    for pkg in "${packages[@]}"; do
        if is_installed "$pkg"; then
            skip "$pkg already installed"
        else
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        info "Installing: ${to_install[*]}"
        paru -S --noconfirm "${to_install[@]}"
        for pkg in "${to_install[@]}"; do
            success "$pkg installed"
        done
    fi
}
