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

export DOCKER_BUILDKIT=1
export EDITOR=nvim
export GPG_TTY=$(tty)
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANWIDTH=999
export ZK_NOTEBOOK_DIR=~/notes
# Enable experimental pnpm support in volta
export VOLTA_FEATURE_PNPM=1

export BAT_THEME='Solarized (dark)'

export BUNDLE_RUBYGEMS__PKG__GITHUB__COM=duboisf:$(gh auth token)

[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
