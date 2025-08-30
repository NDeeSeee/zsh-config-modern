# ========================================
# Utility Functions
# ========================================

# Check alias usage function
check_alias_usage() {
  # Only show alias suggestions after shell is fully initialized
  local cmd="${1%% *}"
  
  # Skip if already aliased or is a function
  if alias "$cmd" >/dev/null 2>&1 || type -f "$cmd" >/dev/null 2>&1; then
    return
  fi
  
  # Safely get the command usage count; default to 0 if fc or grep fails
  local count
  count=$(fc -ln 2>/dev/null | grep -Fxc -- "$cmd" 2>/dev/null) || count=0
  # Use arithmetic context to avoid string parsing issues
  if [ "$count" -ge 5 ]; then
    echo "Consider aliasing '${cmd}' (used ${count} times)"
  fi
}

# Path copying functions
_copy_path_full() {
  local target="${1:-.}"
  local abs_path=$(realpath "$target" 2>/dev/null || greadlink -f "$target" 2>/dev/null || echo "$PWD/$target")
  echo -n "$abs_path" | pbcopy
  echo "📋 Copied absolute path: $abs_path"
}

_copy_path_relative() {
  local target="${1:-.}"
  local rel_path
  if [[ "$target" == "." ]]; then
    rel_path="."
  else
    rel_path=$(realpath --relative-to="$PWD" "$target" 2>/dev/null || greadlink --relative-to="$PWD" "$target" 2>/dev/null || echo "$target")
  fi
  echo -n "$rel_path" | pbcopy
  echo "📋 Copied relative path: $rel_path"
}

_copy_path_filename() {
  local target="${1:-.}"
  local filename=$(basename "$target")
  echo -n "$filename" | pbcopy
  echo "📋 Copied filename: $filename"
}

# Buffer copying function for piped input
_copy_to_buffer() {
  local content
  local line_count=0
  local char_count=0
  local preview=""
  
  # Read all input
  content=$(cat)
  
  # Copy to clipboard
  echo -n "$content" | pbcopy
  
  # Generate stats and preview
  if [[ -n "$content" ]]; then
    line_count=$(echo "$content" | wc -l | tr -d ' ')
    char_count=$(echo -n "$content" | wc -c | tr -d ' ')
    
    # Create preview (first 50 chars, truncated)
    preview=$(echo "$content" | head -c 50 | tr '\n' ' ')
    [[ ${#content} -gt 50 ]] && preview="${preview}..."
    
    echo "📋 Copied to buffer: ${line_count} lines, ${char_count} chars"
    echo "   Preview: ${preview}"
  else
    echo "📋 Copied empty content to buffer"
  fi
}

# Debug mode toggle functions
debug_on() {
  set -x  # Enable command tracing
  setopt XTRACE
  setopt VERBOSE
  echo "🔧 Debug mode ON - commands will be traced"
}

debug_off() {
  set +x  # Disable command tracing
  unsetopt XTRACE
  unsetopt VERBOSE
  echo "🔧 Debug mode OFF"
}

# Toggle WARN_CREATE_GLOBAL for diagnostics
warn_globals_on() { setopt WARN_CREATE_GLOBAL; echo "WARN_CREATE_GLOBAL ON"; }
warn_globals_off() { unsetopt WARN_CREATE_GLOBAL; echo "WARN_CREATE_GLOBAL OFF"; }

# Function to show detailed command information
cmd_info() {
  local cmd="$1"
  if [[ -z "$cmd" ]]; then
    echo "Usage: cmd_info <command>"
    return 1
  fi
  
  echo "📋 Information for command: $cmd"
  echo "   Type: $(type -a "$cmd" 2>/dev/null || echo 'Not found')"
  echo "   Location: $(which "$cmd" 2>/dev/null || echo 'Not in PATH')"
  echo "   Version: $("$cmd" --version 2>/dev/null || "$cmd" -v 2>/dev/null || echo 'Version info not available')"
}

# Create a directory and enter it
mkcd() { mkdir -p -- "$1" && builtin cd -- "$1"; }

# Jump to git repo root (or stay if not in a repo)  
git_root() { builtin cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"; }

# ZSH Syntax Highlighting Colorway Showcase
colorshow() {
    local category="${1:-all}"
    
    echo
    echo "🌈 ZSH SYNTAX HIGHLIGHTING COLORWAY SHOWCASE 🌈"
    echo "Demonstrating all command types with their respective colors"
    echo
    
    case "$category" in
        "builtins"|"all")
            echo "🔵 SHELL BUILTINS (Blue Bold):"
            echo "  cd ~/Documents"
            echo "  pwd" 
            echo "  echo 'Hello World'"
            echo "  export PATH=\$PATH:/new/path"
            echo
            ;&
        "functions"|"all")
            echo "🟣 USER FUNCTIONS (Magenta):"
            local user_functions=($(functions | grep -E '^[a-zA-Z_][a-zA-Z0-9_]*' | head -5 | cut -d' ' -f1))
            if [[ ${#user_functions[@]} -gt 0 ]]; then
                for func in $user_functions; do
                    echo "  $func"
                done
            else
                echo "  my_function arg1 arg2"
                echo "  custom_script --option"
            fi
            echo
            ;&
        "aliases"|"all")
            echo "🔵 ALIASES (Cyan):"
            echo "  ll"
            echo "  sz" 
            echo "  ls -la"
            echo
            ;&
        "commands"|"all")
            echo "🟢 EXTERNAL COMMANDS (Green):"
            local common_commands=(git ls cat grep find curl wget npm python)
            local available_commands=()
            for cmd in $common_commands; do
                command -v $cmd >/dev/null 2>&1 && available_commands+=($cmd)
            done
            for cmd in ${available_commands[1,6]}; do
                echo "  $cmd"
            done
            echo
            echo "  Usage examples:"
            echo "  git status"
            echo "  ls -la"
            echo "  grep 'pattern' file.txt"
            echo
            ;&
        "popular"|"all")
            echo "🛠️  POPULAR TOOLS:"
            local dev_tools=(code vim docker npm pip brew conda)
            local available_dev=()
            for tool in $dev_tools; do
                command -v $tool >/dev/null 2>&1 && available_dev+=($tool)
            done
            for tool in ${available_dev[1,8]}; do
                echo "  $tool"
            done
            echo
            ;&
        "syntax"|"all")
            echo "🎨 SYNTAX ELEMENTS:"
            echo "  Quoted strings (yellow):     echo 'hello' \"world\""
            echo "  File paths (white):         /etc/hosts ~/Documents"
            echo "  Options (cyan):             ls -la --color=auto" 
            echo "  Pipes (magenta):            cat file | grep pattern"
            echo "  Globbing (blue):            ls *.txt"
            echo
            ;&
    esac
    
    if [[ "$category" == "all" || "$category" == "" ]]; then
        echo "🎯 COLOR LEGEND:"
        echo "🔵 Blue Bold     - Shell builtins"
        echo "🟣 Magenta       - User functions"  
        echo "🔵 Cyan          - Aliases & options"
        echo "🟢 Green         - External commands"
        echo "🟡 Yellow        - Quoted strings"
        echo "🔴 Red           - Invalid/dangerous commands"
        echo "⚪ White         - File paths (underlined)"
        echo
        echo "Usage: colorshow [category]"
        echo "Categories: builtins, functions, aliases, commands, popular, syntax, all"
    fi
}

# Function to set up utility function hooks
_setup_utility_functions() {
  autoload -Uz add-zsh-hook
  add-zsh-hook preexec check_alias_usage
}