# The basic stuff
alias du='du -h'
alias l='eza -l --color=auto' # cargo install eza
alias la='l -a'
alias open=xdg-open
alias s='cd ..'

# Text manupulation
alias -g C='| print_selected_columns'
alias -g D='| default'
alias -g I='| indent'
alias -g F='| fzf -m --bind "ctrl-a:select-all" --header-lines=1'
alias mh1='mdheading 1'
alias mh2='mdheading 2'
alias mh3='mdheading 3'
alias mh4='mdheading 4'
alias mh5='mdheading 5'
alias mh6='mdheading 6'
alias -g CB='| codeblock'
# view piped markdown text in nvim
alias -g M='| nvim -R -c "set ft=markdown"'

# open nvim in dotfiles folder
alias edot='cd $(git -C ~/.zshrc(:A:h) rev-parse --show-toplevel) && nvim'
# secure nvim for general usage
alias safe-nvim='\nvim --noplugin'
alias nonet-nvim='firejail \
        --net=none \
        --deterministic-shutdown \
        --blacklist=~/.argocd/ \
        --blacklist=~/.aws/ \
        --blacklist=~/.circleci/ \
        --blacklist=~/.config/gh/hosts.yml \
        --blacklist=~/.datadog \
        --blacklist=~/.jfrog/ \
        --blacklist=~/.gnupg/ \
        --blacklist=~/.oci-fred \
        --blacklist=~/.oci/ \
        --blacklist=~/.pulumi/ \
        --blacklist=~/.ssh/ \
        --noprofile \
        nvim --cmd "lua vim.g.no_network = true"'

# firejail
alias fj=firejail
alias fjl='fj --list'
alias fjjl='fj --join=$(fj --list | tail -n 1 | cut -d : -f 1)'
alias fjd='fj --debug'

# need this sometimes
alias whatismyip='curl -s "https://api.ipify.org?format=json" | jq -r .ip'

# Super useful global aliases
_C() {
    # USAGE: _C COLUMN
    # Get column COLUMN from space seperated output
    typeset column=$1
    awk "{ print \$$column }"
}

# DN is for /[D]ev/[N]ull
alias -g DN='/dev/null'
# IE is for Ignore Errors
alias -g IE='2> /dev/null'
# ME is for Merge Errors
alias -g ME='2>&1'
alias -g G='| grep'
alias -g L='| less'
alias -g S='| sort'
alias -g SU='| sort -u'
alias -g V='| nvim -n -R --cmd "let g:pager_mode = 1" '
alias -g X='| xclip -selection clipboard'

# chrome with firejail
alias chrome='GTK_IM_MODULE=xim firejail google-chrome-stable 2> /dev/null &; disown'
# debian and derivatives package management aliases
alias ai='sudo apt install'
alias as='apt search'
alias af='apt-file search'

# golang
alias cover='go test -coverprofile=/tmp/coverage.out ./... && go tool cover -html=/tmp/coverage.out -o ~/Downloads/go-coverage.html && open ~/Downloads/go-coverage.html'

# kitty
alias icat='kitty +kitten icat'

# kubernetes/docker
alias d='docker'
alias bake='docker buildx bake'
alias mk='minikube'

# kubectl
#########
alias k='kubectl'
alias kc='kubectl'
# kctxs returns list of k8s contexts that are not none, can only be used in for loops
# e.g. for ctx in kctxs; do k --context $ctx get no; done
alias -g kctxs='$(kubectl config get-contexts -o name | grep -v none)'
alias skc='kubectl --as=$USER --as-group=system:masters'
alias rpo='kc get po --field-selector=status.phase=Running'
alias po='kc get po'
alias pow='kc get po -o wide'
alias dpo='kc describe po'
alias deploy='kc get deploy'
alias ddeploy='kc describe deploy'
alias logs='kc logs'
alias no='kc get no -L karpenter.sh/provisioner-name -L kubernetes.io/arch -L karpenter.sh/capacity-type -L node.kubernetes.io/instance-type -L karpenter.k8s.aws/instance-cpu -L karpenter.k8s.aws/instance-memory -L dedicated -L karpenter.sh/nodepool'
alias dno='kc describe no'
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
alias -g DS="-o json | jq '. + {"stringData": (.data | map_values(@base64d))} | del(.data, .metadata.managedFields)'"
alias jo='kc get job'
alias djo='kc describe job'
alias cronjob='kc get cronjob'
alias dcronjob='kc describe cronjob'
alias rollouts='kc rollout status'
alias -g CT='--context'
# CTX is useful for for loops.
# e.g for ctx in kctxs; do k CTX get no; done
alias -g CTX='--context $ctx'
alias -g AN='--all-namespaces'
alias -g J='-o json'
alias -g JV='-o json | nvim -R -c "set ft=json"'
alias -g Y='-o yaml'
alias -g YV='-o yaml | nvim -R -c "set ft=yaml"'
alias kubelistall='kubectl api-resources --verbs=list --namespaced -o name | grep -v event | xargs -n 1 kubectl get --show-kind --ignore-not-found'

# git
#####
alias g='git'
alias gb='git branch'
alias gco='git checkout'
alias ga='git add'
alias gap='git add -p'
alias gs='git status --short'
alias gl='git log --decorate'
alias gl1p='git log --decorate -1 -p'
alias gls='git log --decorate --stat'
alias glss='git log --show-signature'
alias gci='git commit -v'
alias gpl='git pull'
alias gf='git fetch --prune'
alias cdg='cd "$(git rev-parse --show-toplevel)"'
alias gciah='git commit --amend -C HEAD'
alias gr='git rebase'
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gd='git diff'
alias gdc='git diff --cached'
alias gw='git worktree'
alias gwl='gw list'
alias gwa='gw add'
alias gwr='gw remove'

# github gh
###########
alias p='gh pr'
alias pc='p checks $(git branch --show-current) --watch'
alias prv='p view'
alias prvw='p view -w'
alias prc='p create'
alias prco='p checkout'
alias prlv='p list -w'
alias -g U='--json url --jq ".[].url"'
alias gsc='gh search code'
alias gsp='gh search prs'
alias gspm='gh search prs --author=@me --state open'
alias gspmu='gspm --json url --jq ".[].url"'
alias gspu='gh search prs U'

# terraform
###########
alias tf=terraform
alias tfi='tf init'
alias tfp='tf plan -out=plan.out'
alias tfa='tf apply plan.out'
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

# helm
#######
alias h=helm
alias hl='h ls'
alias hu='h repo up'
alias hsh='h search hub'
alias hs='h search repo'
alias hsd='h search repo --devel'
alias hru='h repo up'

# pulumi
#########
alias pu=pulumi
alias pl='pulumi stack ls'
alias pss='pulumi stack select'
alias pp='pulumi preview'
alias ppd='pulumi preview --diff'
alias pusl='pulumi stack --show-urns'

# openssl
##########
alias view-cert='openssl x509 -text -noout -in'
alias s_connect='openssl s_client -state -debug -connect'

# aws cli
##########
alias iaws='aws --cli-auto-prompt'
alias ssogroups='aws --no-cli-pager \
    --profile $AWS_IDENTITY_CENTER_PROFILE \
    identitystore list-groups --identity-store-id $IDENTITY_STORE_ID \
    | jq ".Groups[].DisplayName" -r | sort'
alias ssousers='aws --no-cli-pager \
    --profile $AWS_IDENTITY_CENTER_PROFILE \
    identitystore list-users --identity-store-id $IDENTITY_STORE_ID \
    | jq ".Users[].UserName" -r | sort'

# rg
#####
alias rgf='rg --files-with-matches'

alias ic=istioctl

alias be='bundle exec'

alias cpc='nvim -c CopilotChat -c only'

alias kssh='kitten ssh'

alias rgh='rg --hidden'

alias ts=tailscale

alias gc='gcloud'
alias gcal='gc auth login --update-adc'
alias gccl='gc config list'
alias gclp='gc projects list'
alias gcsp='gc config set project'
