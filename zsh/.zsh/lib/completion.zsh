# Load bashcompinit once for all bash-style completions below
if (( $+commands[aws] || $+commands[terraform] )) || [[ -f /usr/lib/google-cloud-sdk/completion.bash.inc ]]; then
    autoload -U +X bashcompinit && bashcompinit
fi

if (( $+commands[aws] )); then
    complete -C =aws_completer aws
fi

if (( $+commands[terraform] )); then
    complete -o nospace -C =terraform terraform
fi

# gcloud completion (handles missing zsh-specific files by falling back to bash)
if command -v gcloud >/dev/null; then
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
    source "${sdk_root}/completion.bash.inc"
  fi
fi

# Makefile completion: show only targets, not files and targets
zstyle ':completion:*:*:make:*' tag-order 'targets'

# Register custom git subcommands for completion
zstyle ':completion:*:*:git:*' user-commands merge-worktree:'merge worktree branch and remove worktree'
