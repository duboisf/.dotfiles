# vim:ft=zsh ts=2 sw=2 sts=2 et

prompt_vpn() {
  (( $+commands[ip] || $+commands[jq] )) && return
  ip link show vpn0 &> /dev/null || return
  local vpn_name=$(ip -json link show up type veth | \
    jq -r '.[].ifname | split("-")[0]' 2> /dev/null)
  [[ -z $vpn_name ]] && return
  prompt_segment red white " $vpn_name🔒 "
}

prompt_last_bg=NONE
prompt_last_fg=NONE
prompt_hard_sep='\ue0b0'
prompt_soft_sep='\ue0b1'
prompt_hard_rsep='\ue0b2'
prompt_soft_rsep='\ue0b3'

prompt_req_sep() {
  if (( $# != 3 )); then
    print "USAGE: $0 SEP FG BG" >&2
    return 1
  fi
  prompt_last_sep=${1:-hard}
  prompt_last_fg=${2:-NONE}
  prompt_last_bg=${3:-NONE}
}

prompt_write_pending_sep() {
  local bg=${1:-NONE}
  case $prompt_last_sep in
    hard)
      print -n "%F{$prompt_last_fg}%K{$bg}$prompt_hard_sep"
      ;;
    rhard)
      print -n "%F{$bg}%K{$prompt_last_bg}$prompt_hard_rsep"
      ;;
    soft)
      local sep=$prompt_soft_sep
      if [[ $bg != $prompt_last_bg ]]; then
        sep=$prompt_hard_sep
      fi
      print -n "%F{$prompt_last_fg}%K{$prompt_last_bg}$sep"
      ;;
    rsoft)
      local sep=$prompt_soft_rsep
      if [[ $bg != $prompt_last_bg ]]; then
        sep=$prompt_hard_rsep
      fi
      print -n "%F{$prompt_last_fg}%K{$prompt_last_bg}$sep"
      ;;
    *);;
  esac
  prompt_last_sep=
}

prompt_write() {
  local fg=${1:-NONE}
  local bg=${2:-NONE}
  prompt_write_pending_sep $bg
  print -n "%F{$fg}%K{$bg}$3"
}

prompt_hard_sep() {
  local fg=${1:-NONE}
  local bg=${2:-NONE}
  prompt_last_bg=$bg
  prompt_last_sep_func='prompt_hard_sep'
  print -n "%F{$fg}%K{$bg}\ue0b0"
}

prompt_kube_context() {
  if (( $+commands[kubectl] )) && [[ $(kubectl config current-context) != off ]]; then
    local full_ctx=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.cluster}/{.contexts[0].context.namespace}')
    local kube_ctx="${full_ctx%/*}"
    local kube_ns="${full_ctx#*/}"
    if [[ -n $kube_ctx ]]; then
      prompt_write black '#cb4b16' " ﴱ "
      prompt_req_sep hard '#cb4b16' black
      prompt_write '#cb4b16' black " $kube_ctx "
      if [[ -n $kube_ns ]]; then
        prompt_req_sep soft '#cb4b16' black
        prompt_write '#cb4b16' black " $kube_ns "
      fi
      prompt_req_sep hard black NONE
    fi
  fi
}

prompt_dir() {
  emulate -RL zsh
  local cwd=$(print -P "%~")
  local parts=(${(s|/|)cwd})
  local path=
  [[ ${cwd[1]} != '~' ]] && path+=/
  prompt_write black blue ' \ue613 ' # folder icon
  local bg=black
  [[ $cwd == / ]] && bg=NONE
  prompt_req_sep hard blue $bg
  while (( $#parts > 0 )); do
    part=${parts[1]}
    parts=(${parts:1})
    path="${path}${part}/"
    if [[ -r ${~path}.git/index ]]; then
      prompt_write blue black ' \uf408' # github icon
    fi
    prompt_write blue black " $part "
    if (( $#parts > 0 )); then
      prompt_req_sep soft blue black
    else
      prompt_req_sep hard black blue
    fi
  done
}

prompt_fred() {
  prompt_dir
  prompt_kube_context
  prompt_write NONE NONE '\n'
  prompt_write black magenta ' \uf120 ' # console icon
  prompt_req_sep hard magenta NONE
  prompt_write magenta NONE '%f%k '
}

prompt_fred_rprompt() {
  emulate -RL zsh
  (( $+commands[git] )) || return
  [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != true ]] && return
  local fg=green
  local bg=black
  git diff --quiet --ignore-submodules || fg=yellow
  prompt_req_sep rsoft black NONE
  prompt_write $fg black " \uf418 $(command git rev-parse --abbrev-ref HEAD) "
  prompt_req_sep rhard $fg black
  prompt_write black $fg " \uf09b "
}

prompt_fred_precmd() {
  PROMPT=$(prompt_fred)
  ZLE_RPROMPT_INDENT=0
  RPROMPT=$(prompt_fred_rprompt)
  print -n '%f%k'
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_fred_precmd
