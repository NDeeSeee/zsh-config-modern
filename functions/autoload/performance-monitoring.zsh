# ========================================
# Smart Performance and Error Monitoring System
# ========================================

# Declare globals explicitly to avoid WARN_CREATE_GLOBAL in hooks
typeset -g _command_start_time=""
typeset -g _command_pid=""
typeset -g _monitor_job=""
typeset -g _last_command=""

# Error code meanings for better diagnostics
typeset -gA ERROR_MEANINGS
ERROR_MEANINGS[1]="General error"
ERROR_MEANINGS[2]="Misuse of shell builtins"
ERROR_MEANINGS[126]="Command invoked cannot execute (permissions)"
ERROR_MEANINGS[127]="Command not found"
ERROR_MEANINGS[128]="Invalid argument to exit"
ERROR_MEANINGS[130]="Script terminated by Ctrl+C"
ERROR_MEANINGS[255]="Exit status out of range"

_smart_timer_preexec() {
  [[ -o interactive ]] || return
  _command_start_time=$SECONDS
  _command_pid=""
  _last_command="$1"  # Store the command for error reporting
}

_smart_timer_precmd() {
  emulate -L zsh
  setopt localoptions no_warn_create_global nonotify
  local exit_code=$?
  [[ -o interactive ]] || { _command_start_time=""; return; }
  
  # Kill any running monitor
  [[ -n $_monitor_job ]] && kill $_monitor_job 2>/dev/null
  _monitor_job=""
  
  if [[ -n $_command_start_time ]]; then
    local elapsed=$(($SECONDS - $_command_start_time))
    
    # Smart reporting based on duration
    if [[ $elapsed -gt 60 ]]; then
      echo >&2 "⏱️  Long command completed: ${elapsed}s ($(($elapsed/60))m $(($elapsed%60))s)"
    elif [[ $elapsed -gt 10 ]]; then
      echo >&2 "⏱️  Command took ${elapsed}s"
    fi
    
    _command_start_time=""
  fi
  
  # Enhanced error reporting with context
  if [[ $exit_code -ne 0 ]]; then
    local error_meaning="${ERROR_MEANINGS[$exit_code]:-Unknown error}"
    echo >&2 "❌ Command failed with exit code $exit_code: $error_meaning"
    
    # Show the command that failed (truncate if too long)
    if [[ -n $_last_command ]]; then
      local cmd_display="$_last_command"
      [[ ${#cmd_display} -gt 80 ]] && cmd_display="${cmd_display:0:80}..."
      echo >&2 "   Command: $cmd_display"
    fi
    
    # Provide context-specific suggestions
    case $exit_code in
      126) echo >&2 "   💡 Try: chmod +x <file> or check file permissions" ;;
      127) echo >&2 "   💡 Try: which <command> or check if command is installed" ;;
      130) echo >&2 "   💡 Command was interrupted by Ctrl+C" ;;
      2)   echo >&2 "   💡 Check command syntax and arguments" ;;
    esac
  fi
  
  # Clear the last command
  _last_command=""
}

# Background monitor for long-running commands
_background_monitor() {
  local start_time=$1
  local command_line="$2"
  local parent_pid=$$
  
  sleep 10
  # Check if parent still exists
  kill -0 "$parent_pid" 2>/dev/null || return
  
  local elapsed=$(($SECONDS - $start_time))
  if [[ $elapsed -ge 10 ]]; then
    echo >&2 "🔄 Long command running: ${elapsed}s - $command_line"
  fi
  
  sleep 20  # Total 30s
  kill -0 "$parent_pid" 2>/dev/null || return
  
  elapsed=$(($SECONDS - $start_time))
  if [[ $elapsed -ge 30 ]]; then
    echo >&2 "🔄 Still running: ${elapsed}s - $command_line"
    
    # Monitor every minute after 30s
    while kill -0 "$parent_pid" 2>/dev/null; do
      sleep 60
      elapsed=$(($SECONDS - $start_time))
      echo >&2 "🔄 Running: $(($elapsed/60))m $(($elapsed%60))s"
    done
  fi
}

_enhanced_preexec() {
  emulate -L zsh
  setopt localoptions no_warn_create_global nomonitor nonotify
  [[ -o interactive ]] || return
  # Kill any existing monitor first
  [[ -n $_monitor_job ]] && kill $_monitor_job 2>/dev/null
  _monitor_job=""
  
  _command_start_time=$SECONDS
  local command_line="$1"
  local cmd="${command_line%% *}"
  
  # Skip simple assignments
  [[ "$command_line" == [A-Za-z_][A-Za-z0-9_]*=* ]] && return
  
  # Exclude common instant commands
  case "$cmd" in
    source|exec|cd|ls|ll|la|pwd|echo|cat|which|type|alias|history|jobs|fg|bg|kill|ps|grep|awk|sed|head|tail|wc|sort|uniq|tr|cut|basename|dirname|whoami|id|date|clear|exit|logout|true|false|test|help|man|info)
      return ;;
  esac
  
  # Only monitor commands likely to be long-running (by command name)
  case "$cmd" in
    make|cmake|cargo|npm|yarn|pip|brew|docker|git|curl|wget|ssh|scp|rsync|tar|zip|unzip|find|locate|sleep|wait)
      _background_monitor "$_command_start_time" "$command_line" &
      _monitor_job=$!
      ;;
  esac
}

# Function to register performance monitoring hooks
_setup_performance_monitoring() {
  autoload -Uz add-zsh-hook
  add-zsh-hook preexec _enhanced_preexec
  add-zsh-hook precmd _smart_timer_precmd
}

# Enhanced error tracking function
last_error() {
  echo "Last command exit status: $?"
  [[ -n "$_last_command" ]] && echo "Last command: $_last_command"
}