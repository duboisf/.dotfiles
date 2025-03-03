if [[ -d $HOME/.pyenv ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    path=($PYENV_ROOT/bin $path)
fi

if [[ -d $HOME/.volta ]]; then
    export VOLTA_HOME="$HOME/.volta"
    path=($VOLTA_HOME/bin $path)
fi

path=(
  ~/.local/bin
  /snap/bin
  $path
)

function () {
    local optional_paths=(
        /usr/local/go/bin
        ~/.ghcup/bin
        ~/.krew/bin
        ~/.pulumi/bin
        ~/.rbenv/bin
        ~/.tfenv/bin
        ~/go/bin
    )

    for d in $optional_paths; do
        if [[ -d $d ]]; then
            path=($d $path)
        fi
    done
}

# Inform difftastic that I use a light terminal background
export DFT_BACKGROUND=light
export DOCKER_BUILDKIT=1
export EDITOR=nvim
export GPG_TTY=$(tty)
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export ZK_NOTEBOOK_DIR=~/notes
# Enable experimental pnpm support in volta
export VOLTA_FEATURE_PNPM=1

export BAT_THEME='Solarized (dark)'

export JAVA_HOME=/usr/lib/jvm/jdk-23.0.1-oracle-x64

if (( $+commands[systemctl] )); then
  if systemctl --user --quiet is-active docker.service; then
      # Using docker in rootless mode
      export DOCKER_HOST=unix://${XDG_RUNTIME_DIR}/docker.sock
  fi
fi

# Prevent "WARNING: Getting tokens from fapi backend failed." message
# when using ssh with TPM2-stored keys
export TPM2_PKCS11_LOG_LEVEL=0
