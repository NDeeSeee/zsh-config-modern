# ========================================
# Performance Optimizations
# ========================================

# On-demand byte-compilation for faster startup
if command -v zcompile >/dev/null 2>&1; then
  if [[ -s ~/.zshrc && ( ! -s ~/.zshrc.zwc || ~/.zshrc -nt ~/.zshrc.zwc ) ]]; then
    zcompile ~/.zshrc
  fi
fi

# Re-apply PATH uniqueness after external init scripts may have modified PATH
_cleanup_path() {
  typeset -U path
  export PATH
}