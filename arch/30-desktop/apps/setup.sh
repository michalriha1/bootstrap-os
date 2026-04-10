#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

info "Installing desktop apps..."
install_packages \
    zen-browser-bin \
    steam
