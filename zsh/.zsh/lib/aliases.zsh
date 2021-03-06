# The basic stuff
alias l='exa -l --color=auto'
alias la='l -a'
alias s='cd ..'
alias open=xdg-open
alias vim=nvim

# open vim in dotfiles folder
alias edot='cd $(git -C ~/.zshrc(:A:h) rev-parse --show-toplevel) && vim'

# Super useful global aliases
_C() {
    # USAGE: _C COLUMN
    # Get column COLUMN from space seperated output
    typeset column=$1
    awk "{ print \$$column }"
}
alias -g C='| _C'
alias -g G='| grep'
alias -g L='| less'
alias -g V='| nvim -n -R --cmd "let g:pager_mode = 1" '
alias -g S='| sort'
alias -g SU='| sort -u'

# debian and derivatives package management aliases
alias ai='sudo apt install'
alias as='apt search'
alias af='apt-file search'

# kitty
alias icat='kitty +kitten icat'

# kubernetes/docker
alias d='docker'
alias mk='minikube'
alias kns=kubens
alias kctx=kubectx

# kubectl
#########
alias kc='kubectl'
alias skc='kubectl --as=$USER --as-group=system:masters'
alias rpo='kc get po --field-selector=status.phase=Running'
alias po='kc get po'
alias dpo='kc describe po'
alias deploy='kc get deploy'
alias ddeploy='kc describe deploy'
alias logs='kc logs'
alias no='kc --as=$USER --as-group=system:masters get no'
alias dno='kc --as=$USER --as-group=system:masters describe no'
alias svc='kc get svc'
alias dsvc='kc describe svc'
alias rs='kc rollout status'
alias ds='kc get ds'
alias dds='kc describe ds'
alias configmap='kc get configmap'
alias dconfigmap='kc describe configmap'
alias cm='kc get configmap'
alias dcm='kc describe configmap'
alias secret='kc get secret'
alias dsecret='kc describe secret'
# base64 decode kubebernetes secrets
alias -g DS="-o yaml | yq --yaml-roundtrip '. + {"stringData": (.data | map_values(@base64d))} | del(.data)'"
alias jo='kc get job'
alias djo='kc describe job'
alias cronjob='kc get cronjob'
alias dcronjob='kc describe cronjob'
alias rollouts='kc rollout status'
alias -g CT='--context'
alias -g AN='--all-namespaces'
alias -g J='-o json'
alias -g Y='-o yaml'
alias kubelistall='kubectl api-resources --verbs=list --namespaced -o name | grep -v event | xargs -n 1 kubectl get --show-kind --ignore-not-found'

# git
#####
alias g='git'
alias gb='git branch'
alias gco='git checkout'
alias ga='git add'
alias gs='git status --short'
alias gl='git log --decorate'
alias gl1p='git log --decorate -1 -p'
alias gls='git log --decorate --stat'
alias gci='git commit -v'
alias gpl='git pull'
alias cdg='cd "$(git rev-parse --show-toplevel)"'
alias gciah='git commit --amend -C HEAD'
alias gr='git rebase'
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gd='git diff'
alias gdc='git diff --cached'

# github gh
###########
alias p='gh pr'
alias prv='p view'
alias prc='p create'
alias prco='p checkout'
alias prlv='p list -w'

# terraform
###########
alias tf=terraform
alias tfi='tf init'
alias tfp='tf plan -out=plan.out'
alias tfpc='tfp | perl -wlne "/^(..0m)?(\s{6}\S)/ or /^..0m$/ or print"'
alias tfs='tf show plan.out'
alias tfsc='tfs | perl -wlne "/^(..0m)?(\s{6}\S)/ or /^(..0m){1,2}$/ or print"'
alias tfv='tf validate'
alias tfsl='tf state list'
alias tfss='tf state show'
alias tfw='tf workspace'
alias tfwl='tfw list'
alias tfws='tfw select'
alias tfwss='tfw show'

# golang
########
alias rdlv='dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient'

# on debian-based distros, fd is called fdfind
if (( $+commands[fdfind] )); then
    alias fd=fdfind
fi

# helm
#######
alias h=helm
alias hl='h ls'
alias hu='h repo up'
alias hsh='h search hub'
alias hs='h search repo'
alias hsd='h search repo --devel'
alias hru='h repo up'
