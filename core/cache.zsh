# ========================================
# High-Performance Caching System with TTL
# ========================================
# Advanced caching for expensive operations with automatic expiration

# Cache storage: associative arrays will be initialized in _init_cache_system

# Default TTL values (in seconds)
readonly _DEFAULT_TTL=60
readonly _DIR_STATS_TTL=30
readonly _PROJECT_DETECT_TTL=120
readonly _TOOL_CHECK_TTL=300

# Get current timestamp (using $SECONDS for performance)
_cache_now() {
  echo ${SECONDS%.*}  # Remove fractional part to avoid float issues
}

# Cache key sanitization (replace problematic characters)
_cache_key() {
  local key="$1"
  # Replace slashes and spaces with underscores for safe key names
  echo "${key//[\/\ ]/_}"
}

# Store value in cache with TTL
# Usage: _cache_set key value [ttl]
_cache_set() {
  local safe_key="$(_cache_key "$1")"
  local value="$2"
  local ttl="${3:-$_DEFAULT_TTL}"
  local current_time="$(_cache_now)"
  
  # Ensure key is not empty and is safe for array subscript
  [[ -z "$safe_key" ]] && return 1
  
  _PERF_CACHE_DATA[$safe_key]="$value"
  _PERF_CACHE_TIME[$safe_key]="$current_time"
  _PERF_CACHE_TTL[$safe_key]="$ttl"
}

# Get value from cache if not expired
# Usage: _cache_get key
# Returns: cached value if valid, empty if expired/missing
_cache_get() {
  local safe_key="$(_cache_key "$1")"
  local current_time="$(_cache_now)"
  
  # Ensure key is valid
  [[ -z "$safe_key" ]] && return 1
  
  # Check if key exists
  [[ -z "${_PERF_CACHE_DATA[$safe_key]}" ]] && return 1
  
  # Check if expired
  local cache_time="${_PERF_CACHE_TIME[$safe_key]}"
  local ttl="${_PERF_CACHE_TTL[$safe_key]}"
  
  if [[ $((current_time - cache_time)) -gt $ttl ]]; then
    # Expired - clean up
    unset "_PERF_CACHE_DATA[$safe_key]" "_PERF_CACHE_TIME[$safe_key]" "_PERF_CACHE_TTL[$safe_key]"
    return 1
  fi
  
  # Valid cache hit
  echo "${_PERF_CACHE_DATA[$safe_key]}"
  return 0
}

# Cached directory stats with optimized performance
_cached_dir_stats() {
  local dir="${1:-.}"
  local cache_key="dir_stats_${dir}"
  
  # Try cache first
  local cached_result
  if cached_result="$(_cache_get "$cache_key")"; then
    echo "$cached_result"
    return 0
  fi
  
  # Cache miss - compute stats with performance optimizations
  local dir_count file_count
  
  # Use zsh globbing for maximum performance (no external commands)
  local -a dirs files
  dirs=( "$dir"/*(/N) )     # Only directories, null_glob enabled
  files=( "$dir"/*(.N) )    # Only regular files, null_glob enabled
  
  dir_count=${#dirs}
  file_count=${#files}
  
  local result="$dir_count:$file_count"
  
  # Cache the result
  _cache_set "$cache_key" "$result" "$_DIR_STATS_TTL"
  
  echo "$result"
}

# Cached project detection
_cached_project_detect() {
  local dir="${1:-.}"
  local cache_key="project_${dir}"
  
  # Try cache first
  local cached_result
  if cached_result="$(_cache_get "$cache_key")"; then
    echo "$cached_result"
    return 0
  fi
  
  # Cache miss - detect project type
  local project_type="directory"
  
  # Fast file existence checks (in priority order for performance)
  if [[ -f "$dir/package.json" ]]; then
    project_type="nodejs"
  elif [[ -f "$dir/Cargo.toml" ]]; then
    project_type="rust"
  elif [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/requirements.txt" ]] || [[ -f "$dir/setup.py" ]]; then
    project_type="python"
  elif [[ -f "$dir/docker-compose.yml" ]] || [[ -f "$dir/compose.yml" ]]; then
    project_type="docker"
  elif [[ -f "$dir/Makefile" ]]; then
    project_type="make"
  elif [[ -d "$dir/.git" ]]; then
    project_type="git"
  fi
  
  # Cache the result
  _cache_set "$cache_key" "$project_type" "$_PROJECT_DETECT_TTL"
  
  echo "$project_type"
}

# Cached tool availability check
_cached_has_tool() {
  local tool="$1"
  local cache_key="tool_$tool"
  
  # Try cache first
  local cached_result
  if cached_result="$(_cache_get "$cache_key")"; then
    [[ "$cached_result" == "1" ]] && return 0 || return 1
  fi
  
  # Cache miss - check tool availability
  local result="0"
  if command -v "$tool" >/dev/null 2>&1; then
    result="1"
  fi
  
  # Cache the result
  _cache_set "$cache_key" "$result" "$_TOOL_CHECK_TTL"
  
  [[ "$result" == "1" ]] && return 0 || return 1
}

# Cache cleanup for memory management
_cache_cleanup() {
  local current_time="$(_cache_now)"
  local cleaned=0
  
  # Clean expired entries
  for key in "${(@k)_PERF_CACHE_DATA}"; do
    local cache_time="${_PERF_CACHE_TIME[$key]}"
    local ttl="${_PERF_CACHE_TTL[$key]}"
    
    if [[ $((current_time - cache_time)) -gt $ttl ]]; then
      unset "_PERF_CACHE_DATA[$key]" "_PERF_CACHE_TIME[$key]" "_PERF_CACHE_TTL[$key]"
      ((cleaned++))
    fi
  done
  
  [[ $cleaned -gt 0 ]] && echo "Cache: cleaned $cleaned expired entries"
}

# Cache statistics for debugging
_cache_stats() {
  echo "Performance Cache Statistics:"
  echo "  Total entries: ${#_PERF_CACHE_DATA[@]}"
  echo "  Data size: ${#_PERF_CACHE_DATA[@]} keys"
  echo "  Time tracking: ${#_PERF_CACHE_TIME[@]} entries"
  echo "  TTL settings: ${#_PERF_CACHE_TTL[@]} entries"
  
  if [[ ${#_PERF_CACHE_DATA[@]} -gt 0 ]]; then
    echo "  Cache keys:"
    for key in "${(@k)_PERF_CACHE_DATA}"; do
      local age=$(($((_cache_now)) - ${_PERF_CACHE_TIME[$key]}))
      local ttl="${_PERF_CACHE_TTL[$key]}"
      local status="valid"
      [[ $age -gt $ttl ]] && status="expired"
      echo "    $key: age=${age}s, ttl=${ttl}s ($status)"
    done
  fi
}

# Initialize cache system
_init_cache_system() {
  # Initialize associative arrays for cache storage
  typeset -gA _PERF_CACHE_DATA
  typeset -gA _PERF_CACHE_TIME  
  typeset -gA _PERF_CACHE_TTL
  
  # Set up periodic cleanup (every 5 minutes)
  # This will be called by the performance monitoring system
  _CACHE_SYSTEM_INITIALIZED=1
}