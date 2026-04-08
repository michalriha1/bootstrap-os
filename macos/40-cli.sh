#!/usr/bin/env bash

run_shell() {
  log "Installing Oh My Zsh + plugins"

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    log "Oh My Zsh already installed"
  fi

  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$custom_dir/plugins" "$custom_dir/themes"

  if [[ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions"
  fi

  if [[ ! -d "$custom_dir/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
  fi

  if [[ ! -d "$custom_dir/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k"
  fi

  if [[ -f "$HOME/.zshrc" ]]; then
    if grep -q '^plugins=' "$HOME/.zshrc"; then
      perl -0777 -i -pe 's/^plugins=\([^\)]*\)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/m' "$HOME/.zshrc"
    else
      printf '\nplugins=(git zsh-autosuggestions zsh-syntax-highlighting)\n' >> "$HOME/.zshrc"
    fi

    if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
      perl -0777 -i -pe 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/m' "$HOME/.zshrc"
    else
      printf 'ZSH_THEME="powerlevel10k/powerlevel10k"\n' >> "$HOME/.zshrc"
    fi
  fi
}
