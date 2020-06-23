# vim:ft=zsh ts=2 sw=2 sts=2 et

CURRENT_BG=NONE

# prompt_segment and prompt_end were copied from agnoster's theme
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    print -n "%{$bg%F{$CURRENT_BG}%}\ue0b0$fg%}"
  else
    print -n "%{$bg%}%{$fg%}"
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && print -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  print -n "%K{red}  %k%F{red}\ue0c8 %f"
}

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

prompt_dir() {
  prompt_segment '#268bd2' '#002b36' "  %~ "
}

prompt_newline() {
  print
  CURRENT_BG=NONE
}

# Change branch icon
BRANCH=

prompt_fred() {
  prompt_kube_context
  prompt_dir
  prompt_vpn
  prompt_newline
  prompt_end
  print -n "%f%k "
}

prompt_fred_precmd() {
  PROMPT=$(prompt_fred)
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_fred_precmd
#AGNOSTER_PROMPT_SEGMENTS=(
#  "prompt_kube_context"
#  "prompt_dir_custom"
#  "prompt_vpn"
#  "prompt_end"
#  "prompt_newline"
#  "prompt_status"
#  "prompt_git"
#  "prompt_end"
#)
