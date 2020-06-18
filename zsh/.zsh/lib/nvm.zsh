() {
    typeset -g __LAST_USED_NODE_PATH_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/last_used_node_path"

    if [[ -f $__LAST_USED_NODE_PATH_FILE ]]; then
        local last_node_path=$(cat $__LAST_USED_NODE_PATH_FILE)
        if [[ -n $last_node_path ]]; then
            path=("$last_node_path" $path)
        fi
    else
        mkdir -p ${__LAST_USED_NODE_PATH_FILE:h}
        touch $__LAST_USED_NODE_PATH_FILE
    fi

    # Lazy load nvm and record path to last used node version.
    # This allows use to have node on the $PATH without loading
    # nvm first, since it's slow to load.
    nvm() {
        unfunction nvm
        # using zplug we install nvm.sh but rename it to __init_nvm,
        # see .zshrc
        source __init_nvm
        # copy original nvm function to __real_nvm
        functions[__real_nvm]=$functions[nvm]
        nvm() {
            __real_nvm $@
            if (( $+commands[node] )); then
                # save directory where node is located. We will prepend it to the
                # path next time we start zsh.
                print $commands[node](:h) > $__LAST_USED_NODE_PATH_FILE
            fi
        }
        nvm $@
    }
}
