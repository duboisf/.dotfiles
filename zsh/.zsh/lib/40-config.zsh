# Directory navigation lifehacks
################################

# Define a redraw prompt widget, copied from fzf. Redefining here as to not
# have a dependency on fzf for non-fzf widgets
redraw-prompt () {
    local precmd
    for precmd in $precmd_functions; do
        $precmd
    done
    zle reset-prompt
}
zle -N redraw-prompt

cd-to-parent-directory-widget() {
    cd ..
    local result=$?
    zle redraw-prompt
    return $result
}

# Push to the directory stack on directory change
setopt autopushd

# Editing
#########

# Copy the current buffer into the system clipboard so that you can paste with ctrl-v
copy-to-system-clipboard () {
    local clipboard_cmd
    if (( $+commands[xclip] )); then
        clipboard_cmd=(xclip -selection clipboard)
    elif (( $+commands[wl-copy] )); then
        clipboard_cmd=(wl-copy)
    else
        zle -M "No clipboard command found (xclip/wl-copy)"
        return 1
    fi

    print -rn -- $BUFFER | "${clipboard_cmd[@]}"
}
