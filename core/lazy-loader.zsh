# ========================================
# Lazy Loading System - High Performance
# ========================================
# This system implements lazy loading for expensive functions to achieve
# <200ms startup times by deferring expensive operations until first use

# Global cache for lazy-loaded functions
typeset -A _LAZY_CACHE

# Lazy loading wrapper generator
# Usage: _lazy_wrap function_name loader_function
_lazy_wrap() {
  local func_name="$1"
  local loader_func="$2"
  
  # Create the lazy wrapper function
  eval "
    $func_name() {
      # Load the real function
      unfunction $func_name 2>/dev/null
      $loader_func
      
      # Call the now-loaded function with all arguments
      $func_name \"\$@\"
    }
  "
}

# Lazy load expensive directory intelligence functions
_load_directory_intelligence() {
  # Load the real implementation
  source "$ZSH_CONFIG_DIR/functions/autoload/directory-intelligence.zsh"
  
  # Set up hooks if not already done
  if [[ -z "$_DIR_INTEL_LOADED" ]]; then
    _setup_directory_intelligence
    _DIR_INTEL_LOADED=1
  fi
}

# Lazy load utility functions
_load_utility_functions() {
  # Load the real implementation
  source "$ZSH_CONFIG_DIR/functions/autoload/utility-functions.zsh"
  
  # Set up hooks if not already done  
  if [[ -z "$_UTIL_FUNCS_LOADED" ]]; then
    _setup_utility_functions
    _UTIL_FUNCS_LOADED=1
  fi
}

# Initialize lazy loading for expensive functions
_init_lazy_loading() {
  # Wrap expensive directory intelligence functions
  _lazy_wrap "whereami" "_load_directory_intelligence"
  _lazy_wrap "_get_dir_stats" "_load_directory_intelligence" 
  _lazy_wrap "_detect_project_smart" "_load_directory_intelligence"
  
  # Wrap utility functions that may be called frequently
  _lazy_wrap "colorshow" "_load_utility_functions"
  _lazy_wrap "cmd_info" "_load_utility_functions"
  
  # Mark lazy loading as initialized
  _LAZY_LOADING_INITIALIZED=1
}

# Function to check if lazy loading is working (for debugging)
_lazy_status() {
  echo "Lazy Loading Status:"
  echo "  Initialized: ${_LAZY_LOADING_INITIALIZED:-No}"
  echo "  Directory Intelligence: ${_DIR_INTEL_LOADED:-Not loaded}"
  echo "  Utility Functions: ${_UTIL_FUNCS_LOADED:-Not loaded}"
  echo "  Cache entries: ${#_LAZY_CACHE[@]}"
}