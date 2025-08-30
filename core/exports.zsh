# ========================================
# Environment Variables and Exports
# ========================================

# Java configuration  
export JAVA_HOME="/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

# Development environment variables
export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
export LDFLAGS="-L/opt/homebrew/opt/libxml2/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libxml2/include"
export R_LIBS_USER=~/R/arm64-apple-darwin20/4.5

# Directory colors (if vivid is available)
command -v vivid >/dev/null 2>&1 && export LS_COLORS="$(vivid generate molokai)"

# Conda environment behavior
export CONDA_CHANGEPS1=no
export CONDA_AUTO_ACTIVATE_BASE=false

# Editor preferences
export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"

# Better man pages with bat if available
command -v bat >/dev/null 2>&1 && export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ZSH-specific exports
export ZSH="$HOME/.oh-my-zsh"
export DISABLE_ZSH_COPILOT=true
export ZSH_DISABLE_COMPFIX=true