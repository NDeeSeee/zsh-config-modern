# ========================================
# Amazon Q Configuration
# ========================================

# Amazon Q pre block sourcing (should be at the top of main zshrc)
_source_amazon_q_pre() {
  [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && \
    builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
}

# Amazon Q post block sourcing (should be at the bottom of main zshrc)
_source_amazon_q_post() {
  [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && \
    builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
}

# Check if Amazon Q is installed and set up environment
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]]; then
    export Q_TERM="1"  # Ensure Q_TERM is set
fi

# Amazon Q specific environment variables (only if Q_TERM is set)
if [[ -n "${Q_TERM:-}" ]]; then
    export Q_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,bg=none,bold,underline"
    export Q_AUTOSUGGEST_STRATEGY="inline_shell_completion history completion"
    export Q_COMPLETION_ENHANCED=1
    export Q_COMPLETION_UI_ENABLED=1
    export Q_RICH_COMPLETIONS=1
fi