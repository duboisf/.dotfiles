# zmodload zsh/zprof

# define some XDG variables
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$UID}

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

export ZPLUG_LOG_LOAD_FAILURE=true
source ~/.zplug/init.zsh
# Commands

# Plugins
# Add fzf completion and key bindings. Need to execute after compinit, so defer
zplug "junegunn/fzf", use:"shell/*.zsh", defer:2
zplug "eza-community/eza", use:"completions/zsh/_eza", defer:2
zplug "duboisf/kube-switch-context.zsh"
# Reuse oh-my-zsh configs that I'm used to
zplug "lib/completion", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
# Nice syntax highlighting like fish, need to run after compinit (defer:2)
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Theme
# zplug "duboisf/fred.zsh-theme", as:theme
# zplug "~/git/fred.zsh-theme", from:local, as:theme

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

if [[ -d ~/.zsh/completions ]]; then
    fpath=(~/.zsh/completions $fpath)
fi

if [[ -d ~/.zsh/functions ]]; then
    fpath=(~/.zsh/functions $fpath)
fi

zplug load

if [[ -d ~/.zsh/functions ]]; then
    autoload ~/.zsh/functions/*(N)
fi

# Load local config
for file in ~/.zsh/lib/*.zsh ~/.zsh.private/lib/*.zsh(N); do
    source $file
done

if [[ $TERM != "linux" ]]; then
    if (( ${+commands[starship]} )); then
        source <(_zsh_cache_eval starship "starship init zsh")
    fi
else
    PS1='%n@%m:%~%# '
fi
