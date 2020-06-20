source ~/.zplug/init.zsh

# Commands
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf
zplug "stedolan/jq", from:gh-r, as:command, rename-to:jq
zplug "kubernetes/minikube", from:gh-r, as:command
# Lazy load nvm, see .zsh/lib/nvm.zsh
zplug "nvm-sh/nvm", use:"nvm.sh", as:command, rename-to:__init_nvm

# Plugins
# Add fzf completion and key bindings
zplug "junegunn/fzf", use:"shell/*.zsh", defer:2
# Reuse oh-my-zsh configs that I'm used to
zplug "lib/completion", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
# Nice syntax highlighting like fish, need to run after compinit (defer:2)
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Theme
zplug "agnoster/agnoster-zsh-theme", as:theme

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Update fpath to include local completions.
# Need to do this before zplug load as it calls compinit
fpath=(~/.zsh/completions $fpath)

zplug load

# Load local config
for file in ~/.zsh/lib/*.zsh; do
    source $file
done
