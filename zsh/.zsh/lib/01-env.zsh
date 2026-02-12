if [[ -d $HOME/.pyenv ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    path=($PYENV_ROOT/bin $path)
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
        ~/.rbenv/bin
        ~/.tfenv/bin
        ~/go/bin
        ~/.cargo/bin
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

export BAT_THEME='Solarized (dark)'

# Check for rootless docker via socket existence (avoids forking systemctl)
if [[ -S ${XDG_RUNTIME_DIR}/docker.sock ]]; then
    export DOCKER_HOST=unix://${XDG_RUNTIME_DIR}/docker.sock
fi

# Prevent "WARNING: Getting tokens from fapi backend failed." message
# when using ssh with TPM2-stored keys
export TPM2_PKCS11_LOG_LEVEL=0

if (( $+commands[mise] )); then
  source <(_zsh_cache_eval mise "mise activate zsh")
fi

if (( $+commands[zoxide] )); then
  source <(_zsh_cache_eval zoxide "zoxide init zsh")
fi
