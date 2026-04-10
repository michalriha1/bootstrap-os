if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# eval "$(starship init zsh)"
ZSH_THEME="powerlevel10k/powerlevel10k"

# export FZF_DEFAULT_OPTS="--bind=up:previous-history,down:next-history"
# export FZF_DEFAULT_OPTS="--bind=up:up,down:down"
# export FZF_CTRL_R_OPTS="--bind=up:previous-history,down:next-history"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
HYPHEN_INSENSITIVE=true
# Set list of themes to pick from when loading at random
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# Begin CUSTOM ZSH
# FNM_PATH="/Users/michalriha/Library/Application Support/fnm"
# if [ -d "$FNM_PATH" ]; then
#   export PATH="/Users/michalriha/Library/Application Support/fnm:$PATH"
#   eval "`fnm env`"
# fi
# eval "$(fnm env --use-on-cd)"

if [ -z "$DISABLE_ZOXIDE" ]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

alias vim='nvim'

alias ll='ls -lh --color=auto'
alias l='ll -a'
alias claude='/Users/michalriha/.local/bin/claude --allow-dangerously-skip-permissions '
# End CUSTOM ZSH

# export PATH="/opt/homebrew/bin:$PATH"

# Begin Similarweb Toolbox Section (do not edit )
export PATH=/Users/michalriha/.local/bin:$PATH
# End Similarweb Toolbox Section
# Begin Similarweb Devenv Section (do not edit )
# End Similarweb Devenv Section

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
# SLOW - figure out how can be avoided
# fpath=(/Users/michalriha/.docker/completions $fpath)
# autoload -Uz compinit
# compinit
# End of Docker CLI completions

export VISUAL='nvim'
export EDITOR='nvim'

export PATH="$HOME/.local/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
