export alias l = ls

export alias table-to-record = transpose -i -r -d
export alias e = explore --peek
export alias d = describe

export alias du = du -h

# alias d = docker

export alias mk = minikube

# git
#####

export alias g = git
export alias gb = git branch
export alias gco = git checkout
export alias ga = git add
export alias gap = git add -p
export alias gs = git status --short
export alias gl = git log --decorate
export alias gl1p = git log --decorate -1 -p
export alias gls = git log --decorate --stat
export alias glss = git log --show-signature
export alias gci = git commit -v
export alias gpl = git pull
export alias cdg = cd $"(git rev-parse --show-toplevel)"
export alias gciah = git commit --amend --no-edit
export alias gr = git rebase
export alias grc = git rebase --continue
export alias gra = git rebase --abort
export alias gd = git diff
export alias gdc = git diff --cached

# github gh
###########

export alias p = gh pr
export alias pc = gh pr checks --watch
export alias prv = gh pr view
export alias prc = gh pr create
export alias prco = gh pr checkout
export alias prlv = gh pr list -w

# alias -g U='--json url --jq ".[].url"'

export alias gsc = gh search code
export alias gsp = gh search prs
export alias gspm = gh search prs --author=@me --state open
def gspmu [] { gspm --json url | from json | get url }
export alias gspu = gh search prs U

export alias gci = git commit
export alias gciah = git commit --amend --no-edit

# kubectl
#########

export alias k = kubectl
export alias rpo = kubectl get po --field-selector=status.phase=Running
export alias po = kubectl get po
export alias pow = kubectl get po -o wide
export alias dpo = kubectl describe po
export alias deploy = kubectl get deploy
export alias ddeploy = kubectl describe deploy
export alias logs = kubectl logs
export alias no = kubectl get no -L karpenter.sh/provisioner-name -L kubernetes.io/arch -L karpenter.sh/capacity-type -L node.kubernetes.io/instance-type -L karpenter.k8s.aws/instance-cpu -L karpenter.k8s.aws/instance-memory -L dedicated -L karpenter.sh/nodepool
export alias dno = kubectl describe no
export alias svc = kubectl get svc
export alias dsvc = kubectl describe svc
export alias ds = kubectl get ds
export alias dds = kubectl describe ds
export alias cm = kubectl get configmap
export alias dcm = kubectl describe configmap
export alias secret = kubectl get secret
export alias dsecret = kubectl describe secret

# base64 decode kubebernetes secrets
# alias -g DS="-o json | jq '. + {"stringData": (.data | map_values(@base64d))} | del(.data, .metadata.managedFields)'"

export alias jo = kubectl get job
export alias djo = kubectl describe job
export alias cronjob = kubectl get cronjob
export alias dcronjob = kubectl describe cronjob

# pulumi
#########

export alias pu = pulumi
export alias pl = pulumi stack ls
export alias pss = pulumi stack select
export alias pp = pulumi preview
export alias ppd = pulumi preview --diff
export alias pusl = pulumi stack --show-urns
