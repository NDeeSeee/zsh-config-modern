# ========================================
# Broot Configuration
# ========================================

# Load broot shell integration
if [[ -f ~/.config/broot/launcher/zsh/br ]]; then
  source ~/.config/broot/launcher/zsh/br
elif [[ -f ~/.config/broot/launcher/bash/br ]]; then
  source ~/.config/broot/launcher/bash/br
fi