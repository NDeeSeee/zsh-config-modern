# ========================================
# External Tool Integrations
# ========================================

# Initialize external tools AFTER Oh My Zsh (conditional)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"

# iTerm2 integration
[[ -f ~/.iterm2_shell_integration.zsh ]] && source ~/.iterm2_shell_integration.zsh

# Load Powerlevel10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Powerlevel10k instant prompt setup
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi