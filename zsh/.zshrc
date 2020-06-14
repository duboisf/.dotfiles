source ~/.zplug/init.zsh

zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf
zplug "junegunn/fzf", use:"shell/*.zsh"
zplug "kubernetes/minikube", from:gh-r, as:command
zplug "themes/agnoster", from:oh-my-zsh, as:theme
zplug "lib/completion", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

for file in ~/.zsh/lib/*.zsh; do
    source $file
done
