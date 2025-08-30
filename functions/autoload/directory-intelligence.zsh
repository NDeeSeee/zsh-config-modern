# ========================================
# Smart Directory Functions (Fast & Simple)
# ========================================

# Simple cache to avoid repeated expensive operations
typeset -A _SIMPLE_CACHE
_CACHE_DURATION=10  # Cache for 10 seconds only

# Fast project detection with minimal overhead
_detect_project_smart() {
  local dir="$1"
  
  # Quick file existence checks (fastest possible)
  [[ -f "$dir/package.json" ]] && echo "nodejs" && return
  [[ -f "$dir/Cargo.toml" ]] && echo "rust" && return
  [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/requirements.txt" ]] || [[ -f "$dir/setup.py" ]] && echo "python" && return
  [[ -f "$dir/Makefile" ]] && echo "make" && return
  [[ -f "$dir/docker-compose.yml" ]] || [[ -f "$dir/compose.yml" ]] && echo "docker" && return
  [[ -d "$dir/.git" ]] && echo "git" && return
  echo "directory"
}

# Get basic stats with simple caching
_get_dir_stats() {
  local dir="$1"
  local cache_key="${dir//\//_}_stats"
  local current_time=$SECONDS
  
  # Check simple cache
  local cached_time=${_SIMPLE_CACHE["${cache_key}_time"]:-0}
  if [[ $((current_time - cached_time)) -lt $_CACHE_DURATION ]]; then
    echo "${_SIMPLE_CACHE["${cache_key}_data"]}"
    return
  fi
  
  # Quick count (limit to avoid slowdown)
  local dir_count=$(find "$dir" -maxdepth 1 -type d 2>/dev/null | head -50 | wc -l | tr -d ' ')
  local file_count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | head -50 | wc -l | tr -d ' ')
  
  # Cache result
  local result="$dir_count:$file_count"
  _SIMPLE_CACHE["${cache_key}_time"]=$current_time
  _SIMPLE_CACHE["${cache_key}_data"]="$result"
  
  echo "$result"
}

# Fast & Smart location overview (formerly overriding pwd)
whereami() {
  local current_dir=$(command pwd)
  local home_replaced=${current_dir/#$HOME/~}
  
  # Quick file counts (no subprocesses)
  local -a _dirs _files
  _dirs=( ./*(/N) )
  _files=( ./*(.N) )
  local dir_count=${#_dirs}
  local file_count=${#_files}
  
  # Fast project detection (inline)
  local project_type="directory"
  local project_display="📂 Directory"
  local quick_actions=""
  
  if [[ -f "package.json" ]]; then
    project_type="nodejs"
    project_display="📦 \033[34mNode.js\033[0m"
    [[ ! -d "node_modules" ]] && quick_actions+="\033[33m💡 npm install\033[0m "
    local scripts=$(jq -r '.scripts | keys[0:3] | join(" ")' package.json 2>/dev/null)
    [[ -n "$scripts" ]] && quick_actions+="\033[36m$scripts\033[0m"
  elif [[ -f "Cargo.toml" ]]; then
    project_type="rust"
    project_display="🦀 \033[31mRust\033[0m"
    quick_actions+="\033[36mbuild run test\033[0m"
  elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
    project_type="python"
    project_display="🐍 \033[33mPython\033[0m"
    [[ -z "$VIRTUAL_ENV" && -z "$CONDA_DEFAULT_ENV" ]] && [[ -d "venv" || -d ".venv" ]] && quick_actions+="\033[33m💡 activate venv\033[0m"
  elif [[ -f "Makefile" ]]; then
    project_type="make"
    project_display="🔨 \033[35mMake\033[0m"
  elif [[ -f "docker-compose.yml" ]] || [[ -f "compose.yml" ]]; then
    project_type="docker"
    project_display="🐳 \033[34mDocker\033[0m"
    quick_actions+="\033[36mup down logs\033[0m"
  elif [[ -d ".git" ]]; then
    project_type="git"
    project_display="📁 \033[32mGit Repository\033[0m"
  fi
  
  # Git status (if git repo)
  local git_status=""
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
    local uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [[ $uncommitted -gt 0 ]]; then
      git_status="\033[31m●\033[0m${branch} \033[2m($uncommitted)\033[0m"
    else
      git_status="\033[32m●\033[0m${branch}"
    fi
  fi
  
  # Get size info for smaller directories
  local size_info=""
  if [[ $((dir_count + file_count)) -lt 100 ]]; then
    if command -v dust >/dev/null 2>&1; then
      size_info=$(dust -d 0 "$current_dir" 2>/dev/null | tail -1 | awk '{print $1}' 2>/dev/null)
    elif command -v du >/dev/null 2>&1; then
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
}

# Show project/context hints on directory change (use chpwd hook instead of overriding cd)
chpwd_show_context() {
  local current_dir=$(command pwd)
  local project_type=$(_detect_project_smart "$current_dir")
  
  # Only show intelligence for interesting projects
  if [[ "$project_type" != "directory" ]]; then
    local colors_reset='\033[0m' yellow='\033[33m' blue='\033[34m' green='\033[32m' red='\033[31m' cyan='\033[36m' dim='\033[2m'
    local suggestions=""
    
    case $project_type in
      "nodejs")
        [[ ! -d "node_modules" ]] && suggestions+="${yellow}💡 npm install${colors_reset} "
        [[ -f "package.json" ]] && {
          local scripts=$(jq -r '.scripts | keys[0:2] | join(", ")' package.json 2>/dev/null)
          [[ -n "$scripts" ]] && suggestions+="${cyan}Available: $scripts${colors_reset}"
        }
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
    
    # Show git status if repo has changes
    if git rev-parse --git-dir >/dev/null 2>&1; then
      local uncommitted=$(git status --porcelain -uno 2>/dev/null | wc -l | tr -d ' ')
      [[ $uncommitted -gt 0 ]] && suggestions+=" ${red}⚠ $uncommitted uncommitted changes${colors_reset}"
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