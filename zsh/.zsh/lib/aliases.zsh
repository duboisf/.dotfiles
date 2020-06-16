# The basic stuff
alias l='ls -lh --color'
alias la='l -a'
alias s='cd ..'
alias pd=popd
alias open=xdg-open
alias vim=nvim

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
alias -g V='| vim -n -R -'
alias -g S='| sort'
alias -g SU='| sort -u'

# debian and derivatives package management aliases
alias ai='sudo apt install'
alias as='apt search'
alias af='apt-file search'

# kubernetes/docker aliases
alias d='docker'
alias mk='minikube'
alias kc='kubectl'
alias kns=kubens
alias kctx=kubectx
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
alias jo='kc get job'
alias djo='kc describe job'
alias cronjob='kc get cronjob'
alias dcronjob='kc describe cronjob'
alias rollouts='kc rollout status'
alias -g CT='--context'
alias -g AN='--all-namespaces'
alias -g J='-o json'
alias -g Y='-o yaml'

# git
alias g='git'
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

# github hub aliases, if hub is installed
if (( $+commands[hub] )); then
    alias git='hub'
fi
# terraform
alias tf=terraform
alias tfi='tf init'
alias tfp='tf plan -out=plan.out'
alias tfpc='tfp | perl -wlne "/^(..0m)?(\s{6}\S)/ or /^..0m$/ or print"'
alias tfs='tf show plan.out'
alias tfsc='tfs | perl -wlne "/^(..0m)?(\s{6}\S)/ or /^(..0m){1,2}$/ or print"'
alias tfv='tf validate'
alias tfsl='tf state list'
alias tfss='tf state show'

# Misc
alias setup_monitors='xrandr --output DP-1-1-2 --mode 2560x1440 --rotate right --output DP-1-3 --mode 2560x1440 --right-of DP-1-1-2 --output eDP-1-1 --mode 2560x1440 --right-of DP-1-3'
alias rdlv='dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient'
alias tn='tmux new -s'
alias ta='tmux attach -t'
