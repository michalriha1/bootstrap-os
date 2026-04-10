#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

ssh_key="${HOME}/.ssh/id_ed25519"

if [[ -f "$ssh_key" ]]; then
    skip "SSH key already exists at $ssh_key"
    exit 0
fi

info "Generating SSH key..."
mkdir -p "${HOME}/.ssh"
ssh-keygen -t ed25519 -f "$ssh_key" -N ""
success "SSH key generated at $ssh_key"
