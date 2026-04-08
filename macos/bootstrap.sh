#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../dotfiles" 2>/dev/null && pwd || true)"
APPLY_MACOS_DEFAULTS="${APPLY_MACOS_DEFAULTS:-true}"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/10-homebrew.sh"
source "$SCRIPT_DIR/20-ssh.sh"
source "$SCRIPT_DIR/30-dotfiles.sh"
source "$SCRIPT_DIR/40-cli.sh"
source "$SCRIPT_DIR/50-macos.sh"

usage() {
  cat <<'EOF'
Usage:
  ./bootstrap.sh                # run all categories
  ./bootstrap.sh brew ssh       # run only selected categories

Categories:
  brew      Homebrew + Brewfile packages
  ssh       SSH key setup
  dotfiles  Link ../dotfiles into $HOME
  shell     Oh My Zsh + plugins + powerlevel10k
  macos     macOS defaults tweaks
EOF
}

run_category() {
  case "$1" in
    brew) run_homebrew ;;
    ssh) run_ssh ;;
    dotfiles) run_dotfiles ;;
    shell) run_shell ;;
    macos) run_macos ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      warn "Unknown category: $1"
      usage
      exit 1
      ;;
  esac
}

main() {
  log "Bootstrap started"

  if [[ $# -eq 0 ]]; then
    run_homebrew
    run_ssh
    run_dotfiles
    run_shell
    run_macos
  else
    local category
    for category in "$@"; do
      run_category "$category"
    done
  fi

  log "Done. Restart terminal (or run: exec zsh)."
}

main "$@"
