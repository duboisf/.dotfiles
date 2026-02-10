# Completion
############

# Don't autocomplete . and .., this is set in oh-by-zsh/lib/completion.zsh
zstyle ':completion:*' special-dirs false

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

# Recently visited directories
##############################

# Every time we change directories record it in the recently
# visited directories list

# This variable is used to force the evaluation of the
# custom_chpwd_recent_dirs hook, see below
typeset -g force_chpwd_recent_dirs=0

# The following function is copied from chpwd_recent_dirs.
# We add an extra mechanism to force it to run on demand.
# This is necessary to be able to record recently visited
# directories when changing directories from zle widgets, because
# when chpwd_recent_dirs triggers, the ZSH_EVAL_CONTEXT isn't
# toplevel so the original chpwd_recent_dirs hook would skip.
# The mechanism is simple, if the force_chpwd_recent_dirs var
# is non-zero, we don't skip. The force_chpwd_recent_dirs is recent
# at the end of the function.
custom_chpwd_recent_dirs () {
    emulate -L zsh
    setopt extendedglob
    local -aU reply
    integer changed
    typeset -g force_chpwd_recent_dirs
    autoload -Uz chpwd_recent_filehandler chpwd_recent_add
    if (( $force_chpwd_recent_dirs == 0 )); then
        if [[ ! -o interactive || $ZSH_SUBSHELL -ne 0 || ( -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT != toplevel(:[a-z]#func|)# ) ]]; then
            return
        fi
    fi
    chpwd_recent_filehandler
    if [[ $reply[1] != $PWD ]]; then
        chpwd_recent_add $PWD && changed=1
        (( changed )) && chpwd_recent_filehandler $reply
    fi
    force_chpwd_recent_dirs=0
}

autoload -Uz cdr add-zsh-hook
add-zsh-hook chpwd custom_chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 1000
# Don't record ~ and /, kinda useless to do so
zstyle ':chpwd:*' recent-dirs-prune pattern:"^$HOME$" pattern:'^/$'

# fuzzy find a semi-recently visited folder
cdr-widget() {
    emulate -L zsh
    setopt err_return localoptions pipefail
    local reply selected_dir_choice
    while true; do
        # store recently visited dirs in the reply variable
        cdr -r
        local selected_dir_choice=("${(@f)$(print ${(F)${(D)reply}} \
            | fzf --height='20%' --layout=reverse --info=hidden \
                --header='Recently visited directories (ctrl-d to delete an entry)' \
                --expect=ctrl-d
                )}")
        if [[ -z $selected_dir_choice ]]; then
            zle redisplay
            return 0
        fi
        if [[ $selected_dir_choice[1] == ctrl-d ]]; then
            # we want to delete the selected entry
            cdr -P $selected_dir_choice[2]
        else
            cd $~selected_dir_choice[2]
            local result=$?
            zle redraw-prompt
            return $result
        fi
    done
}

# END Recently visited directories

# history
#########

# from the manual for share_history: This option both imports new commands from
# the history file, and also causes your typed commands to be appended to the
# history file"
setopt share_history

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
