# ========================================
# PATH Configuration (consolidated)
# ========================================
# Use array form for clarity and de-duplication
typeset -U path

# Core system and homebrew paths
path=(
  /opt/homebrew/bin
  /opt/homebrew/sbin
  ~/.local/bin
  ~/bin
  /usr/local/bin
  $path
)

# Language-specific paths
[[ -d ~/Library/Python/3.9/bin ]] && path=(~/Library/Python/3.9/bin $path)
[[ -d /Library/Frameworks/R.framework/Resources/bin ]] && path=(/Library/Frameworks/R.framework/Resources/bin $path)
[[ -d /opt/homebrew/opt/openjdk/bin ]] && path=(/opt/homebrew/opt/openjdk/bin $path)

# Conda/mamba base CLI tools (alto, fissfc) without activating base
[[ -d /opt/homebrew/Caskroom/mambaforge/base/bin ]] && path=(/opt/homebrew/Caskroom/mambaforge/base/bin $path)

# Custom tools directory (user-specific)
[[ -d ~/custom_tools ]] && path=(~/custom_tools $path)

# GNU coreutils (must come after Homebrew is in PATH)
if command -v brew >/dev/null 2>&1; then
  [[ -d $(brew --prefix)/opt/coreutils/libexec/gnubin ]] && path=($(brew --prefix)/opt/coreutils/libexec/gnubin $path)
fi

# Export the final PATH
export PATH