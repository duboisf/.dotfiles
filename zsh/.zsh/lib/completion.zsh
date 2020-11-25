
if (( $+commands[kubectl] )); then
    local _kubectl_path=$(dirname $0)/../completions/_kubectl
    if [[ ! -f _kubectl_path ]]; then
        kubectl completion zsh > $_kubectl_path
    fi
    unset _kubectl_path
fi
