# ========================================
# Conda/Mamba Configuration
# ========================================

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
if [[ -x /opt/homebrew/bin/mamba ]]; then
  export MAMBA_EXE='/opt/homebrew/bin/mamba'
  export MAMBA_ROOT_PREFIX=~/.local/share/mamba
  
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__mamba_setup"
  else
      alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
  fi
  unset __mamba_setup
fi
# <<< mamba initialize <<<