# ========================================
# Shell Options
# ========================================

# Notification and error handling options
setopt NOTIFY              # notify immediately when jobs finish
setopt noclobber          # prevent accidental overwrites with > (use >| to override)  
setopt pipefail           # make pipelines fail if any component fails
setopt ERR_RETURN         # return from function on error
setopt PRINT_EXIT_VALUE   # print exit values of commands that exit non-zero

# Disable problematic options for interactive shells
unsetopt WARN_CREATE_GLOBAL  # too noisy with plugins
unsetopt correct_all         # disable typo correction

# Note: ERR_EXIT and VERBOSE disabled - use debug_on/trace for verbose mode
# Note: NO_UNSET disabled as it conflicts with Oh My Zsh initialization
# Note: CORRECT_ALL available but disabled - use debug functions for diagnostics