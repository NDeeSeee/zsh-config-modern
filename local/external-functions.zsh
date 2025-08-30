# ========================================
# External Function Loading
# ========================================

# Load all .zsh files from ~/.zsh_functions directory
if [[ -d ~/.zsh_functions ]]; then
    for func_file in ~/.zsh_functions/*.zsh(N); do
        [[ -f "$func_file" ]] && source "$func_file"
    done
fi

# Load organized aliases from separate file
if [[ -f ~/.zsh_config/aliases.zsh ]]; then
  source ~/.zsh_config/aliases.zsh
  echo "✅ Loaded aliases from ~/.zsh_config/aliases.zsh" >&2
else
  echo "❌ Aliases file not found: ~/.zsh_config/aliases.zsh" >&2
fi

# Load specific function modules if present
for f in \
  ~/.zsh_functions/list_commands.zsh \
  ~/.zsh_functions/demo_commands.zsh \
  ~/.zsh_functions/list_variables.zsh \
  ~/.zsh_functions/list_environments.zsh \
  ~/.zsh_functions/help_system.zsh \
  ~/.zsh_functions/list_credentials.zsh
do
  [[ -f $f ]] && source "$f"
done