source ~/.zplug/init.zsh

# Commands
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf
zplug "stedolan/jq", from:gh-r, as:command, rename-to:jq
zplug "kubernetes/minikube", from:gh-r, as:command

# Plugins
# Add fzf completion and key bindings
zplug "junegunn/fzf", use:"shell/*.zsh"
# Reuse oh-my-zsh configs that I'm used to
zplug "lib/completion", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
# Nice syntax highlighting like fish, need to run after compinit (defer:2)
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Theme
zplug "themes/agnoster", from:oh-my-zsh, as:theme

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

# Load local config
for file in ~/.zsh/lib/*.zsh; do
    source $file
done
