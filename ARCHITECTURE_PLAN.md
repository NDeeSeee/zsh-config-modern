# ZSH Configuration Modular Architecture Plan

## Current State Analysis

### Performance Bottlenecks Identified
- **Startup time**: 900+ lines executed sequentially on every shell start
- **Expensive operations**: Multiple `find` commands, `du` operations, and subshells
- **Redundant PATH manipulations**: PATH modified in multiple locations
- **Hardcoded paths**: `/Users/pavb5f` throughout configuration
- **Massive code duplication**: Multiple similar functions and repeated patterns
- **No lazy loading**: All functions loaded immediately
- **Hook system overhead**: Multiple hooks executed on every command/directory change

### Key Issues Found
1. **Lines 378-379**: `find` commands with `-maxdepth 1` in `_get_dir_stats` on every directory change
2. **Lines 447-453**: `dust` or `du` calls in `whereami` function
3. **Lines 18-41**: Complex PATH construction executed on every startup
4. **Lines 352-356**: All `.zsh` files sourced immediately from `~/.zsh_functions`
5. **Lines 887-896**: Redundant function loading at end of file
6. **Lines 435-443**: Git status checks on every directory change
7. **Lines 171-291**: Complex monitoring system with background processes

## Target Modular Architecture

```
~/.config/zsh/
├── zshrc                    # Main entry point (<100 lines)
├── core/
│   ├── exports.zsh         # Environment variables
│   ├── options.zsh         # Shell options
│   ├── paths.zsh           # PATH management
│   └── hooks.zsh           # Essential hooks only
├── plugins/
│   ├── completion.zsh      # Completion configuration
│   ├── history.zsh         # History settings
│   ├── syntax.zsh          # Syntax highlighting
│   └── prompt.zsh          # Prompt configuration
├── functions/
│   ├── autoload/           # Lazy-loaded functions
│   │   ├── finfo
│   │   ├── whereami
│   │   ├── colorshow
│   │   └── ...
│   └── utils.zsh           # Utility functions
├── tools/
│   ├── external.zsh        # External tool initialization
│   ├── amazon-q.zsh        # Amazon Q specific config
│   └── conda.zsh           # Conda/mamba configuration
├── local/
│   ├── secrets.env         # Environment secrets
│   ├── machine.zsh         # Machine-specific config
│   └── aliases.zsh         # Personal aliases
└── cache/
    ├── completions/        # Cached completions
    └── functions/          # Compiled functions
```

## Performance Targets

| Metric | Current | Target | Strategy |
|--------|---------|--------|----------|
| Shell startup | ~1-2s | <200ms | Lazy loading, caching |
| Directory changes | ~300-500ms | <50ms | Cache git status, remove expensive ops |
| Command execution | ~50-100ms | <10ms | Optimize hooks, remove monitoring |

## Implementation Strategy

### Phase 1: Core Modularization (High Impact)
1. **Create main `zshrc` entry point**
   - Load only essential core modules
   - Set up autoload paths
   - Initialize caching system

2. **Extract core modules**
   - `core/exports.zsh`: Environment variables (lines 44-60)
   - `core/options.zsh`: Shell options (lines 64-73)
   - `core/paths.zsh`: Optimized PATH construction (lines 18-41)

3. **Implement lazy loading for functions**
   - Convert all custom functions to autoload format
   - Move to `functions/autoload/` directory
   - Remove immediate sourcing

### Phase 2: Performance Optimization (Critical)
1. **Cache expensive operations**
   - Git status caching with TTL
   - Directory stats caching
   - Project type detection caching

2. **Optimize monitoring system**
   - Remove complex background monitoring (lines 171-291)
   - Simplify to essential error reporting only
   - Use async where possible

3. **Eliminate redundant operations**
   - Single PATH construction
   - Remove duplicate function loading
   - Consolidate similar functionality

### Phase 3: Plugin System (Medium Impact)
1. **External tool management**
   - Conditional loading based on tool availability
   - Async initialization where possible
   - Proper error handling for missing tools

2. **Completion optimization**
   - Lazy load completions
   - Cache completion results
   - Remove redundant completion setup

### Phase 4: Local Configuration (Low Impact)
1. **Secrets management**
   - Extract hardcoded paths
   - Environment-based configuration
   - Secure secrets handling

2. **Machine-specific config**
   - Portable configuration system
   - Local overrides support

## Detailed Implementation Plan

### 1. Main zshrc Structure
```bash
# ~/.config/zsh/zshrc (target: <100 lines)
#!/usr/bin/env zsh

# Performance monitoring (optional)
typeset -g _ZSHRC_START_TIME=$SECONDS

# Configuration directory
export ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Core modules (essential only)
source "$ZSH_CONFIG_DIR/core/exports.zsh"
source "$ZSH_CONFIG_DIR/core/options.zsh"
source "$ZSH_CONFIG_DIR/core/paths.zsh"

# Set up autoload paths
fpath=("$ZSH_CONFIG_DIR/functions/autoload" $fpath)
autoload -Uz $ZSH_CONFIG_DIR/functions/autoload/*(:t)

# Plugin system (lazy where possible)
source "$ZSH_CONFIG_DIR/plugins/completion.zsh"
source "$ZSH_CONFIG_DIR/plugins/history.zsh"

# Conditional plugin loading
[[ -n "$SYNTAX_HIGHLIGHTING" ]] && source "$ZSH_CONFIG_DIR/plugins/syntax.zsh"

# External tools (async/conditional)
source "$ZSH_CONFIG_DIR/tools/external.zsh"

# Local configuration
[[ -f "$ZSH_CONFIG_DIR/local/machine.zsh" ]] && source "$ZSH_CONFIG_DIR/local/machine.zsh"

# Performance reporting
(( ${_ZSHRC_START_TIME:-0} )) && {
  echo "zsh startup: $((($SECONDS - $_ZSHRC_START_TIME) * 1000))ms" >&2
  unset _ZSHRC_START_TIME
}
```

### 2. Core Modules

#### core/exports.zsh
- Environment variables
- Tool-specific exports
- No command execution

#### core/paths.zsh
- Single, optimized PATH construction
- Conditional path additions
- Deduplication built-in

#### core/options.zsh
- All shell options
- No external dependencies

### 3. Function Optimization

#### Current Problems:
- `whereami`: Calls `dust`, `du`, `jq`, `git` synchronously
- `_get_dir_stats`: Uses `find` on every call
- Git status checks on every directory change

#### Solutions:
```bash
# Cached git status with TTL
_git_status_cached() {
  local cache_key="${PWD//\//_}_git"
  local cache_time_key="${cache_key}_time"
  local current_time=$SECONDS
  
  # Check cache (5 second TTL)
  if [[ $((current_time - ${_CACHE[$cache_time_key]:-0})) -lt 5 ]]; then
    echo "${_CACHE[$cache_key]}"
    return
  fi
  
  # Update cache
  local status
  if git rev-parse --git-dir >/dev/null 2>&1; then
    status="$(git symbolic-ref --short HEAD 2>/dev/null):$(git status --porcelain 2>/dev/null | wc -l)"
    _CACHE[$cache_key]="$status"
    _CACHE[$cache_time_key]="$current_time"
  fi
  
  echo "$status"
}
```

### 4. Migration Strategy

#### Step 1: Backup and Initialize
```bash
# Backup current configuration
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)

# Initialize git repository
cd ~/.config/zsh
git init
git add .
git commit -m "Initial zsh modular architecture setup"
```

#### Step 2: Incremental Migration
1. Create core modules first
2. Test each module independently
3. Migrate functions one by one
4. Performance test after each change
5. Rollback capability at each step

#### Step 3: Performance Validation
```bash
# Startup time testing
time zsh -c 'exit'

# Directory change testing  
time (cd /tmp && cd -)

# Command overhead testing
time echo "test"
```

## Expected Performance Improvements

### Startup Time Reduction
- **Current**: 1-2 seconds (900+ lines, multiple subshells)
- **Target**: <200ms (essential loading only)
- **Strategy**: Lazy loading, caching, minimal startup code

### Directory Change Optimization
- **Current**: 300-500ms (git status, find commands, du operations)
- **Target**: <50ms (cached operations, minimal hooks)
- **Strategy**: TTL caching, async operations, simplified detection

### Memory Usage
- **Current**: High (all functions loaded, multiple caches)
- **Target**: Minimal (autoload functions, shared cache)
- **Strategy**: Lazy loading, efficient caching, cleanup

## Risk Mitigation

### Compatibility Issues
- Maintain backward compatibility aliases
- Progressive migration approach
- Extensive testing on different environments

### Performance Regression
- Benchmark at each step
- Rollback procedures
- Performance monitoring built-in

### Configuration Loss
- Git-based version control
- Backup procedures
- Documentation of all changes

## Success Metrics

1. **Startup time < 200ms** (measured via `time zsh -c 'exit'`)
2. **Directory change < 50ms** (measured via hook timing)
3. **Maintainable code** (< 100 lines main config, modular structure)
4. **No functionality loss** (all current features preserved)
5. **Portable configuration** (no hardcoded paths)

## Next Steps

1. **Immediate**: Create git repository and backup current config
2. **Phase 1**: Implement core modularization (1-2 days)
3. **Phase 2**: Performance optimization (2-3 days)  
4. **Phase 3**: Plugin system refinement (1 day)
5. **Phase 4**: Local configuration and cleanup (1 day)

Total estimated time: 5-7 days for complete migration with testing.