#!/usr/bin/env bash

run_ssh() {
  local key_path="$HOME/.ssh/id_ed25519"

  if [[ -f "$key_path" ]]; then
    log "SSH key already exists: $key_path"
    return
  fi

  log "Creating SSH key"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  local email
  email="$(git config --global user.email || true)"
  if [[ -z "$email" ]]; then
    email="${SSH_KEY_EMAIL:-$(whoami)@$(scutil --get LocalHostName 2>/dev/null || echo macbook)}"
  fi

  ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N ""

  if [[ "$(uname)" == "Darwin" ]]; then
    ssh-add --apple-use-keychain "$key_path" 2>/dev/null || ssh-add -K "$key_path" 2>/dev/null || true
    if ! grep -q "IdentityFile ~/.ssh/id_ed25519" "$HOME/.ssh/config" 2>/dev/null; then
      cat >> "$HOME/.ssh/config" <<'EOF'
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
      chmod 600 "$HOME/.ssh/config"
    fi
  fi

  log "Public key:"
  cat "${key_path}.pub"
}
