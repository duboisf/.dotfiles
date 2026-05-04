skip_global_compinit=1
if [[ -d "$HOME/.cargo/env" ]]; then
    . "$HOME/.cargo/env"
fi

export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
