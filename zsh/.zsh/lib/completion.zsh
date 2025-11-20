
if (( $+commands[aws] )); then
    autoload -U +X bashcompinit && bashcompinit
    complete -C =aws_completer aws
fi

if (( $+commands[terraform] )); then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C =terraform terraform
fi

# gcloud completion (handles missing zsh-specific files by falling back to bash)
if command -v gcloud >/dev/null; then
  # sdk_root="$(gcloud info --format='value(installation.sdk_root)')"
  sdk_root="/usr/lib/google-cloud-sdk"

  # PATH setup
  if [ -f "${sdk_root}/path.zsh.inc" ]; then
    source "${sdk_root}/path.zsh.inc"
  elif [ -f "${sdk_root}/path.bash.inc" ]; then
    source "${sdk_root}/path.bash.inc"
  fi

  # Completion setup
  if [ -f "${sdk_root}/completion.zsh.inc" ]; then
    fpath+=("${sdk_root}/completion.zsh.inc")
  elif [ -f "${sdk_root}/completion.bash.inc" ]; then
    autoload -U +X bashcompinit && bashcompinit
    source "${sdk_root}/completion.bash.inc"
  fi
fi
