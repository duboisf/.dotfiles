if [[ -f ~/.last_used_node_path ]]; then
    path=("$(cat ~/.last_used_node_path)" $path)
fi

# Skip this file if nvm isn't installed
if (( ! $+commands[_init_nvm] )); then
    return
fi

# Lazy load nvm and record path to last used node version.
# This allows use to have node on the $PATH without loading
# nvm first, since it's slow to load.
nvm() {
    unfunction nvm
    # using zplug we install nvm.sh but rename it to _init_nvm.sh,
    # see .zshrc
    source _init_nvm
    functions -c nvm _real_nvm
    nvm() {
        _real_nvm $@
        if (( $+commands[node] )); then
            echo $commands[node](:h) > ~/.last_used_node_path
        fi
    }
    nvm $@
}
