export PYENV_ROOT="$HOME/.pyenv"
export VOLTA_HOME="$HOME/.volta"

path=(
  ~/.rbenv/bin
  $PYENV_ROOT/bin
  $VOLTA_HOME/bin
  ~/.tfenv/bin
  ~/.krew/bin
  ~/.local/bin
  /snap/bin
  ~/go/bin
  /usr/local/go/bin
  ~/.pulumi/bin
  $path
)

if [[ -d ~/.tfenv/bin ]]; then
    path=(~/.tfenv/bin $path)
fi

# Inform difftastic that I use a light terminal background
export DFT_BACKGROUND=light
export DOCKER_BUILDKIT=1
export EDITOR=nvim
export GPG_TTY=$(tty)
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANWIDTH=999
export ZK_NOTEBOOK_DIR=~/notes
# Enable experimental pnpm support in volta
export VOLTA_FEATURE_PNPM=1

export BAT_THEME='Solarized (dark)'

if systemctl --user --quiet is-active docker.service; then
    # Using docker in rootless mode
    export DOCKER_HOST=unix://${XDG_RUNTIME_DIR}/docker.sock
fi
