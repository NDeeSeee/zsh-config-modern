# ========================================
# Google Cloud SDK Configuration
# ========================================

# The next line updates PATH for the Google Cloud SDK.
[[ -f ~/google-cloud-sdk/path.zsh.inc ]] && source ~/google-cloud-sdk/path.zsh.inc

# The next line enables shell command completion for gcloud.
[[ -f ~/google-cloud-sdk/completion.zsh.inc ]] && source ~/google-cloud-sdk/completion.zsh.inc

# Demote Google Cloud SDK in PATH so it doesn't override Homebrew/user tools
_demote_gcloud_in_path() {
  if (( ${path[(Ie)$HOME/google-cloud-sdk/bin]} )); then
    path=(${path:#$HOME/google-cloud-sdk/bin})
    path+=($HOME/google-cloud-sdk/bin)
    export PATH
  fi
}