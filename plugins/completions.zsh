# ========================================
# Completion Configuration
# ========================================

# Amazon Q completion optimizations (only if Q_TERM is set)
if [[ -n "${Q_TERM:-}" ]]; then
    zstyle ':completion:*' menu select=2
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    zstyle ':completion:*' verbose true
    zstyle ':completion:*:descriptions' format '%B%d%b'
    zstyle ':completion:*:messages' format '%d'
    zstyle ':completion:*:warnings' format 'No matches for: %d'
    zstyle ':completion:*' group-name ''
    
    # Enable completion caching
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path ~/.zsh/cache
    
    # Better file completion
    zstyle ':completion:*:*:*:*:*' menu select
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    
    # Git completions
    zstyle ':completion:*:git:*' tag-order 'heads:-branch:branch\ names'
    zstyle ':completion:*:*:git:*' user-commands true
fi