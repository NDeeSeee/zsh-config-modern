# ========================================
# Smart Directory Functions (Performance Optimized)
# ========================================
# Using the new caching and helper systems for maximum performance

# Fast project detection using new helper system
_detect_project_smart() {
  local dir="$1"
  detect_project "$dir"
}

# Get basic stats using new caching system
_get_dir_stats() {
  local dir="$1"
  get_dir_stats "$dir"
}

# Fast & Smart location overview (Performance Optimized)
whereami() {
  time_start "whereami"
  
  local current_dir=$(command pwd)
  local home_replaced=${current_dir/#$HOME/~}
  
  # Get directory stats using cached system
  local stats_result=$(get_dir_stats "$current_dir")
  local dir_count="${stats_result%%:*}"
  local file_count="${stats_result##*:}"
  
  # Fast project detection using cached system
  local project_type=$(detect_project "$current_dir")
  local project_display="📂 Directory"
  local quick_actions=""
  
  case $project_type in
    "nodejs")
      project_display="📦 \033[34mNode.js\033[0m"
      [[ ! -d "node_modules" ]] && quick_actions+="\033[33m💡 npm install\033[0m "
      if has_tool jq; then
        local scripts=$(jq -r '.scripts | keys[0:3] | join(" ")' package.json 2>/dev/null)
        [[ -n "$scripts" ]] && quick_actions+="\033[36m$scripts\033[0m"
      fi
      ;;
    "rust")
      project_display="🦀 \033[31mRust\033[0m"
      quick_actions+="\033[36mbuild run test\033[0m"
      ;;
    "python")
      project_display="🐍 \033[33mPython\033[0m"
      [[ -z "$VIRTUAL_ENV" && -z "$CONDA_DEFAULT_ENV" ]] && [[ -d "venv" || -d ".venv" ]] && quick_actions+="\033[33m💡 activate venv\033[0m"
      ;;
    "make")
      project_display="🔨 \033[35mMake\033[0m"
      ;;
    "docker")
      project_display="🐳 \033[34mDocker\033[0m"
      quick_actions+="\033[36mup down logs\033[0m"
      ;;
    "git")
      project_display="📁 \033[32mGit Repository\033[0m"
      ;;
  esac
  
  # Git status using helper function
  local git_status=""
  local git_info=$(get_git_status)
  if [[ $? -eq 0 ]]; then
    local git_clean_status="${git_info%%:*}"
    local branch="${git_info#*:}"
    branch="${branch%:*}"
    local uncommitted="${git_info##*:}"
    
    if [[ "$git_clean_status" == "dirty" ]]; then
      git_status="\033[31m●\033[0m${branch} \033[2m($uncommitted)\033[0m"
    else
      git_status="\033[32m●\033[0m${branch}"
    fi
  fi
  
  # Get size info for smaller directories (using cached tool check)
  local size_info=""
  if [[ $((dir_count + file_count)) -lt 100 ]]; then
    if has_tool dust; then
      size_info=$(dust -d 0 "$current_dir" 2>/dev/null | tail -1 | awk '{print $1}' 2>/dev/null)
    elif has_tool du; then
      size_info=$(du -sh "$current_dir" 2>/dev/null | cut -f1)
    fi
  fi

  # Build output (send to stderr to avoid polluting stdout)
  >&2 echo
  >&2 echo -e "\033[1m\033[44m 🧠 INTELLIGENT LOCATION \033[0m"
  >&2 echo -e "📍 \033[1m\033[33m${home_replaced}\033[0m"
  >&2 echo
  >&2 echo -e "$project_display \033[2m|\033[0m \033[32m$dir_count\033[0m dirs \033[35m$file_count\033[0m files"
  
  [[ -n "$size_info" && "$size_info" != "0B" ]] && >&2 echo -e "💾 \033[1mSize:\033[0m \033[35m$size_info\033[0m"
  [[ -n "$git_status" ]] && >&2 echo -e "🔧 $git_status"
  [[ -n "$quick_actions" ]] && >&2 echo -e "⚡ $quick_actions"
  
  >&2 echo
  
  time_end "whereami"
}

# Show project/context hints on directory change (Performance Optimized)
chpwd_show_context() {
  local current_dir=$(command pwd)
  local project_type=$(detect_project "$current_dir")
  
  # Only show intelligence for interesting projects
  if [[ "$project_type" != "directory" ]]; then
    local colors_reset='\033[0m' yellow='\033[33m' blue='\033[34m' green='\033[32m' red='\033[31m' cyan='\033[36m' dim='\033[2m'
    local suggestions=""
    
    case $project_type in
      "nodejs")
        [[ ! -d "node_modules" ]] && suggestions+="${yellow}💡 npm install${colors_reset} "
        if [[ -f "package.json" ]] && has_tool jq; then
          local scripts=$(jq -r '.scripts | keys[0:2] | join(", ")' package.json 2>/dev/null)
          [[ -n "$scripts" ]] && suggestions+="${cyan}Available: $scripts${colors_reset}"
        fi
        ;;
      "python")
        [[ -z "$VIRTUAL_ENV" && -z "$CONDA_DEFAULT_ENV" ]] && [[ -d "venv" || -d ".venv" ]] && suggestions+="${yellow}💡 Activate virtual environment${colors_reset}"
        ;;
      "rust")
        suggestions+="${cyan}cargo build, run, test${colors_reset}"
        ;;
      "docker")
        suggestions+="${cyan}docker-compose up/down${colors_reset}"
        ;;
    esac
    
    # Show git status if repo has changes (using optimized helper)
    local git_info=$(get_git_status)
    if [[ $? -eq 0 ]]; then
      local git_clean_status="${git_info%%:*}"
      local uncommitted="${git_info##*:}"
      [[ "$git_clean_status" == "dirty" && $uncommitted -gt 0 ]] && suggestions+=" ${red}⚠ $uncommitted uncommitted changes${colors_reset}"
    fi
    
    # Display suggestions if any
    if [[ -n "$suggestions" ]]; then
      echo -e "${dim}💡 $suggestions${colors_reset}" >&2
    fi
  fi
}

# Function to register directory change hooks
_setup_directory_intelligence() {
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd chpwd_show_context
}