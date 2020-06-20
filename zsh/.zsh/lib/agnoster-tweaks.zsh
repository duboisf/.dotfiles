# vim:ft=zsh ts=2 sw=2 sts=2 et
#
# Tweaks to agnoster's theme https://github.com/agnoster/agnoster-zsh-theme
#
# What was added:
# - kubectl context
# - if current process resides in a network namespace connected to a vpn

# abort if agnoster's theme isn't loaded
(( $+AGNOSTER_PROMPT_SEGMENTS )) || return

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
      prompt_segment '#D26D26' '#000' " ﴱ $kube_ctx "
    fi
  fi
}

prompt_dir_custom() {
  prompt_segment '#268bd2' '#002b36' "  %~ "
}

prompt_newline() {
  echo
  CURRENT_BG=NONE
}

# Change branch icon
BRANCH=

AGNOSTER_PROMPT_SEGMENTS=(
  "prompt_kube_context"
  "prompt_virtualenv"
  "prompt_dir_custom"
  "prompt_vpn"
  "prompt_end"
  "prompt_newline"
  "prompt_status"
  "prompt_git"
  "prompt_end"
)
