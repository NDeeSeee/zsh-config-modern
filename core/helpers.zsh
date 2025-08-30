# ========================================
# Unified Helper Functions - DRY Principle
# ========================================
# Consolidated helper functions to eliminate the 15+ repeated patterns
# throughout the original configuration

# High-performance tool availability check with caching
# Usage: has_tool command_name
has_tool() {
  local tool="$1"
  [[ -z "$tool" ]] && return 1
  
  # Use cached version if cache system is available
  if [[ -n "$_CACHE_SYSTEM_INITIALIZED" ]]; then
    _cached_has_tool "$tool"
  else
    # Fallback to direct check
    command -v "$tool" >/dev/null 2>&1
  fi
}

# Safe PATH addition with duplicate checking
# Usage: add_to_path "/path/to/add" [before|after]
add_to_path() {
  local new_path="$1"
  local position="${2:-after}"
  
  # Skip if path doesn't exist or is already in PATH
  [[ ! -d "$new_path" ]] && return 1
  [[ ":$PATH:" == *":$new_path:"* ]] && return 0
  
  if [[ "$position" == "before" ]]; then
    PATH="$new_path:$PATH"
  else
    PATH="$PATH:$new_path"
  fi
  
  export PATH
}

# Remove path from PATH variable
# Usage: remove_from_path "/path/to/remove"
remove_from_path() {
  local remove_path="$1"
  [[ -z "$remove_path" ]] && return 1
  
  # Remove all instances of the path
  PATH="${PATH//":$remove_path:"/:}"  # Middle occurrences
  PATH="${PATH/#"$remove_path:"/}"    # Beginning occurrence
  PATH="${PATH/%":$remove_path"/}"    # End occurrence
  PATH="${PATH//"$remove_path"/}"     # Standalone occurrence
  
  export PATH
}

# Clean up PATH by removing duplicates and non-existent directories
# Usage: cleanup_path
cleanup_path() {
  local -a path_array clean_path
  local current_path
  
  # Split PATH into array
  IFS=':' read -rA path_array <<< "$PATH"
  
  # Build clean path array
  for current_path in "${path_array[@]}"; do
    # Skip empty entries and non-existent directories
    [[ -z "$current_path" ]] && continue
    [[ ! -d "$current_path" ]] && continue
    
    # Skip duplicates
    [[ " ${clean_path[*]} " == *" $current_path "* ]] && continue
    
    clean_path+=("$current_path")
  done
  
  # Rebuild PATH
  PATH="${(j/:/)clean_path}"
  export PATH
}

# Enhanced project detection with caching
# Usage: detect_project [directory]
detect_project() {
  local dir="${1:-.}"
  
  # Use cached version if available
  if [[ -n "$_CACHE_SYSTEM_INITIALIZED" ]]; then
    _cached_project_detect "$dir"
  else
    # Fallback to direct detection
    _detect_project_direct "$dir"
  fi
}

# Direct project detection (fallback when cache not available)
_detect_project_direct() {
  local dir="$1"
  
  # Fast file existence checks in priority order
  [[ -f "$dir/package.json" ]] && echo "nodejs" && return
  [[ -f "$dir/Cargo.toml" ]] && echo "rust" && return
  [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/requirements.txt" ]] || [[ -f "$dir/setup.py" ]] && echo "python" && return
  [[ -f "$dir/docker-compose.yml" ]] || [[ -f "$dir/compose.yml" ]] && echo "docker" && return
  [[ -f "$dir/Makefile" ]] && echo "make" && return
  [[ -d "$dir/.git" ]] && echo "git" && return
  echo "directory"
}

# Get directory statistics with caching
# Usage: get_dir_stats [directory]
get_dir_stats() {
  local dir="${1:-.}"
  
  # Use cached version if available
  if [[ -n "$_CACHE_SYSTEM_INITIALIZED" ]]; then
    _cached_dir_stats "$dir"
  else
    # Fallback to direct stats
    _get_dir_stats_direct "$dir"
  fi
}

# Direct directory stats (fallback when cache not available)
_get_dir_stats_direct() {
  local dir="$1"
  
  # Use zsh globbing for performance (no external commands)
  local -a dirs files
  dirs=( "$dir"/*(/N) )
  files=( "$dir"/*(.N) )
  
  echo "${#dirs}:${#files}"
}

# Safe source function with error handling
# Usage: safe_source "/path/to/file"
safe_source() {
  local file="$1"
  
  if [[ -r "$file" ]]; then
    source "$file"
    return 0
  else
    echo >&2 "Warning: Cannot source file: $file"
    return 1
  fi
}

# Check if running in specific environments
# Usage: is_ssh, is_tmux, is_vscode, etc.
is_ssh() { [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; }
is_tmux() { [[ -n "$TMUX" ]]; }
is_screen() { [[ -n "$STY" ]]; }
is_vscode() { [[ -n "$VSCODE_SHELL_INTEGRATION" ]]; }
is_iterm() { [[ "$TERM_PROGRAM" == "iTerm.app" ]]; }

# Environment detection helper
# Usage: get_environment
get_environment() {
  is_ssh && echo "ssh" && return
  is_tmux && echo "tmux" && return  
  is_screen && echo "screen" && return
  is_vscode && echo "vscode" && return
  is_iterm && echo "iterm" && return
  echo "terminal"
}

# Git status helper for prompts
# Usage: get_git_status
get_git_status() {
  # Only run if in a git repo
  git rev-parse --git-dir >/dev/null 2>&1 || return 1
  
  local branch uncommitted
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
  uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  
  if [[ $uncommitted -gt 0 ]]; then
    echo "dirty:$branch:$uncommitted"
  else
    echo "clean:$branch:0"
  fi
}

# Performance measurement helpers
# Usage: time_start "operation_name"; ...; time_end "operation_name"

time_start() {
  local name="$1"
  [[ -n "$name" ]] && _PERF_TIMERS[$name]="$SECONDS"
}

time_end() {
  local name="$1"
  [[ -z "$name" ]] && return 1
  
  local start_time="${_PERF_TIMERS[$name]}"
  
  if [[ -n "$start_time" ]]; then
    # Calculate duration and convert to milliseconds  
    local duration_sec=$((SECONDS - start_time))
    local duration_ms=$((duration_sec * 1000))
    echo "Performance: $name took ${duration_ms}ms"
    unset "_PERF_TIMERS[$name]"
  fi
}

# Initialize helper system
_init_helpers() {
  # Initialize associative array for performance timers
  typeset -gA _PERF_TIMERS
  
  # Mark helpers as initialized
  _HELPERS_INITIALIZED=1
}

# Helper system status for debugging
_helpers_status() {
  echo "Helper Functions Status:"
  echo "  Initialized: ${_HELPERS_INITIALIZED:-No}"
  echo "  Active timers: ${#_PERF_TIMERS[@]}"
  [[ ${#_PERF_TIMERS[@]} -gt 0 ]] && echo "  Timer names: ${(k)_PERF_TIMERS}"
}