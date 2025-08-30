# ========================================
# Oh My Zsh Configuration
# ========================================

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh My Zsh plugins (using built-in plugin system)
plugins=(
  git
  web-search
  sudo
  copyfile
  copybuffer
  dirhistory
  docker
  fzf
  history-substring-search
  zsh-syntax-highlighting  # Must be last for proper highlighting
)

# Set completion directories before oh-my-zsh (compinit)
[[ -d ~/.docker/completions ]] && fpath=(~/.docker/completions $fpath)
if command -v brew >/dev/null 2>&1; then
  [[ -d $(brew --prefix)/share/zsh-completions ]] && fpath=($(brew --prefix)/share/zsh-completions $fpath)
  [[ -d $(brew --prefix)/share/zsh/site-functions ]] && fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
fi

# Quietly source Oh My Zsh to avoid WARN_CREATE_GLOBAL noise from plugins
_omz_quiet_source() { 
  emulate -L zsh
  setopt no_warn_create_global
  source $ZSH/oh-my-zsh.sh 
}
_omz_quiet_source
unset -f _omz_quiet_source