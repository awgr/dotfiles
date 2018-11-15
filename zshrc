# Allow local customizations in the ~/.zshrc_local_before file
if [ -f ~/.zshrc_local_before ]; then
    source ~/.zshrc_local_before
fi

# External plugins (initialized before)
source ~/.zsh/plugins_before.zsh

# Settings
source ~/.zsh/settings.zsh

# Bootstrap
source ~/.zsh/bootstrap.zsh

# External settings
source ~/.zsh/external.zsh

# Aliases
source ~/.zsh/aliases.zsh

# Custom prompt
source ~/.zsh/prompt.zsh

# Syntax highlighting
source ~/.zsh/syntax.zsh

# External plugins (initialized after)
source ~/.zsh/plugins_after.zsh 

# Allow local customizations in the ~/.zshrc_local_after file
if [ -f ~/.zsh/zshrc_local_after ]; then
    source ~/.zsh/zshrc_local_after
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/andrew/.sdkman"
[[ -s "/Users/andrew/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/andrew/.sdkman/bin/sdkman-init.sh"
