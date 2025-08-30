# Modular ZSH Configuration

A high-performance, maintainable ZSH configuration split into logical modules for better organization and faster loading.

## Installation

1. **Backup your existing configuration:**
   ```bash
   cp ~/.zshrc ~/.zshrc.backup
   ```

2. **Replace your ~/.zshrc with the modular loader:**
   ```bash
   cp zshrc-replacement ~/.zshrc
   ```

3. **Reload your shell:**
   ```bash
   source ~/.zshrc
   ```

## Structure

```
.
├── core/                    # Core shell configuration
│   ├── exports.zsh         # Environment variables
│   ├── options.zsh         # Shell options and settings
│   └── paths.zsh           # PATH management
├── plugins/                 # Plugin configurations
│   ├── completions.zsh     # Completion settings
│   ├── omz.zsh            # Oh My Zsh configuration
│   └── syntax-highlighting.zsh # Syntax highlighting styles
├── functions/autoload/      # Custom functions
│   ├── aliases.zsh         # Command aliases
│   ├── directory-intelligence.zsh # Smart directory features
│   ├── performance-monitoring.zsh # Command timing and error tracking
│   └── utility-functions.zsh # General utilities
├── tools/                   # External tool integrations
│   ├── amazon-q.zsh        # Amazon Q configuration
│   ├── broot.zsh          # Broot file manager
│   ├── conda-mamba.zsh    # Conda/Mamba setup
│   ├── external-tools.zsh # General external tools
│   └── google-cloud.zsh   # Google Cloud SDK
├── local/                   # Local and external configurations
│   ├── external-functions.zsh # External function loading
│   └── performance.zsh     # Performance optimizations
└── zshrc                   # Main configuration loader
```

## Features

- **Modular Architecture**: Easy to maintain and extend
- **Error Handling**: Graceful degradation when modules are missing
- **Performance Monitoring**: Smart command timing and error reporting
- **Directory Intelligence**: Context-aware project detection
- **Portable Configuration**: No hardcoded paths
- **Safe Loading**: Continues even if individual modules fail

## Key Functions

- `whereami` - Show intelligent directory information
- `colors` - Display syntax highlighting demo
- `debug_on/debug_off` - Toggle command tracing
- `mkcd` - Create and enter directory
- `git_root` - Jump to git repository root

## Performance

The configuration is optimized for fast startup:
- Conditional tool loading
- Minimal subprocesses during initialization
- Cached directory stats
- Byte-compiled configuration files

## Customization

Add your own modules by creating files in the appropriate directories and updating the loading order in `zshrc`.