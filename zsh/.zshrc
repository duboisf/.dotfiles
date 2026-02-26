# zmodload zsh/zprof

# Define XDG variables
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$UID}

# Resolve zsh config directory (follows stow symlinks)
ZSH_DIR="${${(%):-%x}:A:h}/.zsh"

# Cache eval output from slow tool init commands.
# Usage: source <(_zsh_cache_eval <name> <command>)
# Regenerate all caches: zsh-regen-cache
_zsh_cache_eval() {
    local name=$1 cmd=$2
    local cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
    local cache_file=$cache_dir/$name.zsh

    if [[ ! -f $cache_file ]] || () { setopt local_options extended_glob; [[ -n $cache_file(#qN.mh+24) ]] }; then
        mkdir -p $cache_dir
        eval "$cmd" > $cache_file
    fi
    cat $cache_file
}

zsh-regen-cache() {
    local cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
    rm -f $cache_dir/*.zsh
    echo "Cache cleared. Restart your shell to regenerate."
}

# fpath additions
[[ -d $ZSH_DIR/completions ]] && fpath=($ZSH_DIR/completions $fpath)
[[ -d $ZSH_DIR/functions ]]   && fpath=($ZSH_DIR/functions $fpath)

# zsh-autocomplete (handles compinit internally)
zstyle ':autocomplete:*:compinit' arguments -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zstyle ':autocomplete:*' delay 0.1
zstyle ':autocomplete:*' min-input 2
source $ZSH_DIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
bindkey '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select

# Autoload user functions
[[ -d $ZSH_DIR/functions ]] && autoload $ZSH_DIR/functions/*(N)

# Plugins
source $ZSH_DIR/plugins/kube-switch-context.zsh/kube-switch-context.plugin.zsh

# Pre-declare for syntax-highlighting config (set in lib/syntax-highlighting.zsh,
# read by the plugin sourced after the lib loop)
typeset -gA ZSH_HIGHLIGHT_STYLES

# Load config files
for file in $ZSH_DIR/lib/*.zsh ~/.zsh.private/lib/*.zsh(N); do
    source $file
done

# fzf-tab (disabled while testing zsh-autocomplete)
# source $ZSH_DIR/plugins/fzf-tab/fzf-tab.plugin.zsh

# fzf key-bindings and completion (after compinit and mise activation in lib/01-env.zsh)
if (( ${+commands[fzf]} )); then
    source <(_zsh_cache_eval fzf "fzf --zsh")
fi

# Workaround for zsh < 5.9: zsh-autocomplete defers widget creation to precmd
# but binds keys immediately. Pre-register so zsh-syntax-highlighting can wrap them.
# These get overwritten by autocomplete's precmd hook on first prompt.
zle -C menu-search menu-select .autocomplete__complete-word__completion-widget
zle -N recent-paths .autocomplete:async:toggle-context

# Syntax highlighting (must be sourced last, after all widget definitions)
source $ZSH_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Prompt
if [[ $TERM != "linux" ]]; then
    if (( ${+commands[starship]} )); then
        source <(_zsh_cache_eval starship "starship init zsh")
    fi
else
    PS1='%n@%m:%~%# '
fi
