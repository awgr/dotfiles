# Syntax highlighting
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

if [[ "$(tput colors)" == "256" ]]; then
    ZSH_HIGHLIGHT_STYLES[default]=none
    ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=226
    ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=93
    ZSH_HIGHLIGHT_STYLES[alias]=fg=208,bold
    ZSH_HIGHLIGHT_STYLES[builtin]=fg=198,bold
    ZSH_HIGHLIGHT_STYLES[function]=fg=198,bold
    ZSH_HIGHLIGHT_STYLES[command]=fg=198,bold
    ZSH_HIGHLIGHT_STYLES[precommand]=fg=198
    ZSH_HIGHLIGHT_STYLES[commandseparator]=none
    ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=037
    ZSH_HIGHLIGHT_STYLES[path]=fg=51
    ZSH_HIGHLIGHT_STYLES[globbing]=fg=033
    ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=white,underline
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=226,bold
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=226,bold
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=035
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=039
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=040
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=040
    ZSH_HIGHLIGHT_STYLES[assign]=fg=037
fi
