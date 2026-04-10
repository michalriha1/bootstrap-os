#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

bin_path="/usr/local/bin/seamless-login"
source_file="${MODULE_DIR}/assets/seamless-login.c"

backup_path "$bin_path" sudo

info "Compiling seamless-login..."
sudo gcc "$source_file" -o "$bin_path"
sudo chmod +x "$bin_path"
success "seamless-login installed"
