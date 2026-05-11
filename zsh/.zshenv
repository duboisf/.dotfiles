skip_global_compinit=1
if [[ -d "$HOME/.cargo/env" ]]; then
    . "$HOME/.cargo/env"
fi

# mise shims — available to every zsh (interactive or not) without needing the
# precmd activation hook to fire.
if [[ -d "$HOME/.local/share/mise/shims" ]]; then
    path=("$HOME/.local/share/mise/shims" $path)
fi

# export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
