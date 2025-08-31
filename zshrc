#!/usr/bin/env zsh
# ========================================
# Modular ZSH Configuration  
# ========================================
# A streamlined, high-performance shell configuration
# Organized into logical modules for maintainability

# Prevent double-loading
if [[ -n "$ZSH_CONFIG_DIR" ]]; then
  return 0
fi

# Configuration directory
ZSH_CONFIG_DIR="${${(%):-%x}:A:h}"

# Error handling function for module loading
_load_module() {
  local module="$1"
  local file="$ZSH_CONFIG_DIR/$module"
  
  if [[ -f "$file" ]]; then
    source "$file"
  else
    echo >&2 "Warning: Module not found: $module"
    return 1
  fi
}

# Safe module loading with error handling
_safe_load() {
  local modules=("$@")
  local failed_modules=()
  
  for module in "${modules[@]}"; do
    if ! _load_module "$module"; then
      failed_modules+=("$module")
    fi
  done
  
  if [[ ${#failed_modules[@]} -gt 0 ]]; then
    echo >&2 "Failed to load modules: ${(j:, :)failed_modules}"
  fi
}

# ========================================
# Phase 1: Pre-Oh My Zsh Setup
# ========================================

# Amazon Q must be loaded first
_load_module "tools/amazon-q.zsh" && _source_amazon_q_pre

# Powerlevel10k instant prompt (must be early)
_load_module "tools/external-tools.zsh"

# Core configuration
_safe_load \
  "core/exports.zsh" \
  "core/options.zsh" \
  "core/paths.zsh"

# Plugin setup (must be before Oh My Zsh)
_safe_load \
  "plugins/syntax-highlighting.zsh" \
  "plugins/completions.zsh"

# ========================================
# Phase 2: Oh My Zsh and Plugin Loading
# ========================================

_load_module "plugins/omz.zsh"

# ========================================
# Phase 3: Functions and Utilities
# ========================================

# Load and initialize function modules
_safe_load \
  "functions/autoload/performance-monitoring.zsh" \
  "functions/autoload/directory-intelligence.zsh" \
  "functions/autoload/utility-functions.zsh" \
  "functions/autoload/aliases.zsh"

# Initialize function hooks
_setup_performance_monitoring
_setup_directory_intelligence  
_setup_utility_functions

# ========================================
# Phase 4: External Tool Integrations
# ========================================

_safe_load \
  "tools/conda-mamba.zsh" \
  "tools/google-cloud.zsh" \
  "tools/broot.zsh"

# ========================================
# Phase 5: Local and External Configurations
# ========================================

_safe_load \
  "local/external-functions.zsh" \
  "local/performance.zsh"

# ========================================
# Phase 6: Final Cleanup and Optimizations
# ========================================

# Clean up PATH and apply performance optimizations
_cleanup_path
_demote_gcloud_in_path

# Amazon Q post-processing (must be last)
_source_amazon_q_post

# ========================================
# Cleanup
# ========================================

# Remove helper functions from global scope
unset -f _load_module _safe_load

# Display quick tool reference
echo
echo "🚀 Modular ZSH Configuration Loaded"
echo "   • Type 'whereami' for intelligent directory info"
echo "   • Type 'colors' to see syntax highlighting demo"
echo "   • Enhanced error monitoring and performance tracking active"
echo