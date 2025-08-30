# ========================================
# Aliases and Shortcuts
# ========================================

# Clipboard path aliases
alias cpwd='_copy_path_full .'
alias cpr='_copy_path_relative .'
alias cfn='_copy_path_filename .'

# Safer rm and friendlier mkdir
alias rm='rm -i'
alias mkdir='mkdir -pv'

# Enhanced debugging aliases
alias trace='debug_on'     # Start command tracing
alias notrace='debug_off'  # Stop command tracing
alias err='last_error'     # Show last error info
alias cmdinfo='cmd_info'   # Show command information
alias verbose='set -v'     # Enable verbose mode
alias quiet='set +v'       # Disable verbose mode

# Troubleshooting aliases
alias path-check='echo $PATH | tr ":" "\n" | nl'  # Show PATH entries numbered
alias env-grep='env | grep -i'                      # Search environment variables
alias which-all='type -a'                           # Show all locations of a command
alias fix-perms='chmod +x'                          # Quick permission fix
alias check-syntax='zsh -n'                         # Check shell script syntax

# Convenience aliases for colorshow
alias colors="colorshow"
alias syntax-demo="colorshow"  
alias highlight-demo="colorshow all"