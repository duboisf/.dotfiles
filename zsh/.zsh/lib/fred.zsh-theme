# vim:ft=zsh ts=2 sw=2 sts=2 et

prompt_vpn() {
  (( $+commands[ip] || $+commands[jq] )) && return
  ip link show vpn0 &> /dev/null || return
  local vpn_name=$(ip -json link show up type veth | \
    jq -r '.[].ifname | split("-")[0]' 2> /dev/null)
  [[ -z $vpn_name ]] && return
  prompt_segment red white " $vpn_name🔒 "
}

prompt_kube_context() {
  if (( $+commands[kubectl] )) && [[ $(kubectl config current-context) != off ]]; then
    local full_ctx=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.cluster}/{.contexts[0].context.namespace}')
    local kube_ctx="${full_ctx%/*}"
    local kube_ns="${full_ctx#*/}"
    if [[ -n $kube_ctx ]]; then
      if [[ -n $kube_ns ]]; then
        kube_ctx+="=>$kube_ns"
      fi
      prompt_segment '#D26D26' '#000' " ﴱ $kube_ctx"
    fi
  fi
}

prompt_last_bg=NONE
prompt_last_sep_func=

prompt_soft_sep() {
  local fg=${1:-NONE}
  local bg=${2:-NONE}
  prompt_last_sep_func='prompt_soft_sep'
  print -n "%F{$fg}%K{$bg}\ue0b1"
}

prompt_hard_sep() {
  local fg=${1:-NONE}
  local bg=${2:-NONE}
  prompt_last_bg=$bg
  prompt_last_sep_func='prompt_hard_sep'
  print -n "%F{$fg}%K{$bg}\ue0b0"
}

prompt_dir() {
  emulate -RL zsh
  local cwd=$(print -P "%~")
  local parts=(${(s|/|)cwd})
  local path=
  [[ ${cwd[1]} != '~' ]] && path+=/
  print -n "%F{black}%K{blue} \ue613 " # folder icon
  local bg=black
  [[ $cwd == / ]] && bg=NONE
  prompt_hard_sep blue $bg
  while (( $#parts > 0 )); do
    part=${parts[1]}
    parts=(${parts:1})
    path="${path}${part}/"
    print -n "%F{blue}%K{black} "
    if [[ -r ${~path}.git/index ]]; then
      print -n "\uf408 " # github icon
    fi
    print -n "$part "
    if (( $#parts > 0 )); then
      prompt_soft_sep blue black
    else
      prompt_hard_sep black NONE
    fi
  done
}

prompt_fred() {
  local misc_prompt=$(prompt_kube_context)
  misc_prompt="$misc_prompt$(prompt_vpn)"
  if [[ -n "$misc_prompt" ]]; then
    print "$misc_prompt"
  fi
  prompt_dir
  print
  print -n "%K{magenta}%F{black} \uf120 "
  prompt_hard_sep magenta NONE
  print -n "%f%k "
}

prompt_fred_precmd() {
  PROMPT=$(prompt_fred)
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_fred_precmd
