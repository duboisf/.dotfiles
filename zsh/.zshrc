# zmodload zsh/zprof

export XDG_CONFIG_HOME=$HOME/.config

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

eval "$(starship init zsh)"

eval "$(rbenv init -)"
