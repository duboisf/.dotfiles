# zsh-autocomplete (handles compinit internally)
# Sourced from .zshrc before lib files — must run before compinit.

zstyle ':autocomplete:*:compinit' arguments -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zstyle ':autocomplete:*' delay 0.1
zstyle ':autocomplete:*' min-input 4
zstyle ':autocomplete:*' add-semicolon no

source $ZSH_DIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

bindkey '^I' menu-select

# Restore default up/down arrow behavior (history navigation, not autocomplete menu)
bindkey -M emacs \
    "^[OA"  .up-line-or-history \
    "^[[A"  .up-line-or-history \
    "^[OB"  .down-line-or-history \
    "^[[B"  .down-line-or-history
