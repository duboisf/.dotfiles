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

# Copy the current buffer into the system clipboard so that you can paste with ctrl-v.
# Uses OSC 52 so the terminal emulator (kitty) writes the clipboard directly —
# avoids wl-copy, which on GNOME has to spawn a transient toplevel to satisfy
# wl_data_device_manager and steals focus, causing tiling-extension reflows.
copy-to-system-clipboard () {
    local b64
    b64=$(print -rn -- $BUFFER | base64 | tr -d '\n')
    printf '\e]52;c;%s\a' "$b64" > /dev/tty
}
