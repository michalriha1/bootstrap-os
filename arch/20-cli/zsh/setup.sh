#!/usr/bin/env bash
set -euo pipefail
source "${BOOTSTRAP_ROOT}/lib.sh"

install_packages zsh

# oh-my-zsh
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    info "Installing oh-my-zsh (unattended)..."
    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended
    success "oh-my-zsh installed"
else
    skip "oh-my-zsh already installed"
fi

zsh_custom="${HOME}/.oh-my-zsh/custom"

# powerlevel10k theme
p10k_dir="${zsh_custom}/themes/powerlevel10k"
if [[ ! -d "$p10k_dir" ]]; then
    info "Cloning powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    success "powerlevel10k cloned"
else
    skip "powerlevel10k already cloned"
fi

# extra plugins
zsh_autosuggestions_dir="${zsh_custom}/plugins/zsh-autosuggestions"
if [[ ! -d "$zsh_autosuggestions_dir" ]]; then
    info "Cloning zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$zsh_autosuggestions_dir"
    success "zsh-autosuggestions cloned"
else
    skip "zsh-autosuggestions already cloned"
fi

zsh_syntax_highlighting_dir="${zsh_custom}/plugins/zsh-syntax-highlighting"
if [[ ! -d "$zsh_syntax_highlighting_dir" ]]; then
    info "Cloning zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_syntax_highlighting_dir"
    success "zsh-syntax-highlighting cloned"
else
    skip "zsh-syntax-highlighting already cloned"
fi

# configs
dotfiles_dir="${BOOTSTRAP_ROOT}/../dotfiles"

info "Stowing zsh config..."
stow --dir "$dotfiles_dir" --target "$HOME" --restow zsh
success "zsh config stowed"

# default login shell
zsh_bin="$(command -v zsh)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$current_shell" != "$zsh_bin" ]]; then
    info "Changing default shell to $zsh_bin (will prompt for password)..."
    chsh -s "$zsh_bin"
    success "Default shell changed to zsh"
else
    skip "Default shell already zsh"
fi
