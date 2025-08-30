# ========================================
# Syntax Highlighting Configuration
# ========================================

# Configure syntax highlighting BEFORE loading Oh My Zsh
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

# Initialize and configure syntax highlighting styles
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[builtin]='fg=blue,bold'                    # Shell builtins - blue, reliable
ZSH_HIGHLIGHT_STYLES[function]='fg=magenta'                     # User functions - magenta, custom
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'                          # Aliases - cyan, shortcuts
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=green,underline'        # Suffix aliases - green underlined
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=cyan,bold'              # Global aliases - cyan bold
ZSH_HIGHLIGHT_STYLES[command]='fg=green'                       # External commands - green, tools
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=green,bold'           # Cached commands - bright green
ZSH_HIGHLIGHT_STYLES[precommand]='fg=yellow,underline'         # Command modifiers - yellow underlined
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow,bold'           # Reserved words like if, for, etc.
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'              # Unknown/invalid commands
ZSH_HIGHLIGHT_STYLES[path]='fg=white,underline'                # File paths
ZSH_HIGHLIGHT_STYLES[globbing]='fg=blue,bold'                  # Glob patterns
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=blue'              # History expansion
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'       # Single quoted strings
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'       # Double quoted strings
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'       # Dollar quoted strings
ZSH_HIGHLIGHT_STYLES[redirection]='fg=magenta'                 # I/O redirection
ZSH_HIGHLIGHT_STYLES[comment]='fg=black,bold'                  # Comments
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=white,bold'         # Command separators like ;, &, |
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan'           # Short options like -l
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan'           # Long options like --help
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=green,underline'       # Auto directory change

# Load additional highlighting patterns from external file if available
[[ -f ~/Documents/barskilab-workflows/my_local_test_data/extra_zsh_highlighting.zsh ]] && \
  source ~/Documents/barskilab-workflows/my_local_test_data/extra_zsh_highlighting.zsh