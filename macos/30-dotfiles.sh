#!/usr/bin/env bash

run_dotfiles() {
  if [[ -z "$DOTFILES_DIR" || ! -d "$DOTFILES_DIR" ]]; then
    warn "Dotfiles directory not found at ../dotfiles, skipping linking"
    return
  fi

  if ! command -v stow >/dev/null 2>&1; then
    warn "GNU stow is not installed. Run 'bootstrap.sh brew' first (or: brew install stow)."
    return
  fi

  # Explicit list of stow packages to apply on macOS.
  local requested_packages=(zsh pi wezterm btop)
  local packages=()
  local pkg

  for pkg in "${requested_packages[@]}"; do
    if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
      packages+=("$pkg")
    else
      warn "Dotfiles package not found, skipping: $pkg"
    fi
  done

  if [[ ${#packages[@]} -eq 0 ]]; then
    warn "No valid dotfiles packages selected"
    return
  fi

  local src rel target backup_path
  for pkg in "${packages[@]}"; do
    while IFS= read -r -d '' src; do
      rel="${src#${DOTFILES_DIR}/${pkg}/}"
      target="${HOME}/${rel}"
      if [[ -e "$target" && ! -L "$target" ]]; then
        backup_path="${target}.bak"
        warn "Existing file blocks stow target, moving to: $backup_path"
        mv "$target" "$backup_path"
      fi
    done < <(find "${DOTFILES_DIR}/${pkg}" -mindepth 1 \( -type f -o -type l \) -print0)
  done

  log "Stowing selected dotfiles packages from $DOTFILES_DIR"
  (
    cd "$DOTFILES_DIR"
    stow --target="$HOME" --restow "${packages[@]}"
  )

  log "Stowed packages: ${packages[*]}"
}
