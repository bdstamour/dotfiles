# ~/.zshrc

# -----------------------------------------------------------------------------
# Powerlevel10k instant prompt — keep near the top.
# Initialization code that may require console input must go above this block.
# -----------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------------------------------------------------------
# Oh My Zsh
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

# Theme — Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Update behaviour
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 14

# Plugins — keep this minimal.
#   git                     : aliases + prompt helpers for git
#   zsh-autosuggestions     : fish-like history autosuggestions
#   zsh-syntax-highlighting : command line syntax highlighting (load last)
#   fzf                     : fuzzy finder keybindings and completion
#   sudo                    : press ESC twice to prepend sudo
#   docker                  : docker completion + aliases
#   docker-compose          : docker compose completion + aliases
plugins=(
  git
  fzf
  sudo
  docker
  docker-compose
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# -----------------------------------------------------------------------------
# User configuration
# -----------------------------------------------------------------------------
export LANG=en_US.UTF-8

# Preferred editor
export EDITOR='nvim'
export VISUAL='nvim'

# History
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# PATH additions
export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias vim='nvim'
alias vi='nvim'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'

# fd is installed as fdfind on Debian/Ubuntu
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# -----------------------------------------------------------------------------
# Powerlevel10k config — run `p10k configure` or edit ~/.p10k.zsh.
# -----------------------------------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
