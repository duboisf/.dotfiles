source ~/.zplug/init.zsh

zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf
zplug "kubernetes/minikube", from:gh-r, as:command

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load 

for file in ~/.zsh/*.zsh; do
    source $file
done

export EDITOR=vim
export MANPAGER='nvim +Man!'
export MANWIDTH=999
