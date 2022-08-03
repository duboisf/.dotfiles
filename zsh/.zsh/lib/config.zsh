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

# Use Esc-l (or Alt-l) to list directory content
bindkey -s '\el' 'l\n'

cd-to-parent-directory-widget() {
    cd ..
    local result=$?
    zle redraw-prompt
    return $result
}
zle -N cd-to-parent-directory-widget
# Bind Esc+u (or Alt+u) to go up to the parent folder
bindkey '\eu' cd-to-parent-directory-widget

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
    local reply selected_dir
    # store recently visited dirs in the reply variable
    cdr -r
    local selected_dir="$(print ${(F)${(D)reply}} \
        | fzf --height='20%' --layout=reverse --info=hidden --header='Recently visited directories')"
    if [[ -z $selected_dir ]]; then
        zle redisplay
        return 0
    fi
    cd $~selected_dir
    local result=$?
    zle redraw-prompt
    return $result
}
# define the cdr-widget
zle -N cdr-widget
# bind alt-j to the cdr-widget
bindkey '\ej' cdr-widget

# END Recently visited directories

# history
#########

# from the manual for share_history: This option both imports new commands from
# the history file, and also causes your typed commands to be appended to the
# history file"
setopt share_history

# fzf config
############

# Mofify the fzf-history-widget. When pressing enter, it
# immediately executes the history entry; when pressing
# ctrl-e, it puts the history entry on the command line to
# edit it; when pressing ctrl-i, it inserts the history entry
# after the cursor
#   when pressing ctrl-e, put
fzf-history-widget () {
    emulate -L zsh
    local selected num
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
    selected=($(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --expect=ctrl-e,ctrl-i --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd))) 
    local ret=$? 
    if [[ -n "$selected" ]]; then
        local -i execute_directly=1
        local pressed_key
        pressed_key=$selected[1]
        if [[ $pressed_key =~ ctrl-[ei] ]]; then
            execute_directly=0
            shift selected
        fi
        # selected history entry
        num=$selected[1] 
        if [[ -n "$num" ]]; then
            if [[ $pressed_key == ctrl-i ]]; then
                # ctrl-i to insert the selected history entry
                # after the cursor
                RBUFFER=$(builtin history -n $num $num)${RBUFFER}
            else
                zle vi-fetch-history -n $num
            fi
            if (( $execute_directly )); then
                zle accept-line
            fi
        fi
    fi
    zle reset-prompt
    return $ret
}

if (( $+commands[fzf] )); then
    () {
        # In debian based distributions, the fd binary is named fdfind
        local fd_bin_path=${commands[fd]:-$commands[fdfind]}
        if [[ -n $fd_bin_path ]]; then
            # this wrapper is use to set force_chpwd_recent_dirs to
            # 1 so that the custom_chpwd_recent_dirs isn't skipped
            # so that the directories jumped to with fzf-cd-widget
            # are recorded in the recently visited directories
            fzf-cd-widget-wrapper() {
                force_chpwd_recent_dirs=1
                zle fzf-cd-widget
            }
            zle -N fzf-cd-widget-wrapper
            bindkey '\ec' fzf-cd-widget-wrapper
            # Use fd instead of find
            typeset -g FZF_ALT_C_COMMAND
            typeset -g FZF_CTRL_T_COMMAND
            typeset -g FZF_DEFAULT_COMMAND
            # By default fzf uses find, let's use fd instead
            FZF_DEFAULT_COMMAND="$fd_bin_path --type file --follow --hidden --no-ignore"
            FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
            FZF_ALT_C_COMMAND="$fd_bin_path --type directory --follow"
            # Use fd instead of find for zsh completion
            _fzf_compgen_path() fd --hidden --follow --no-ignore . "$1"
            # Use fd to generate the list for directory completion
            _fzf_compgen_dir() fd --type directory --hidden --no-ignore --follow . "$1"
            # This function is used to pass different options to fzf based
            # on the command we are displaying completion for
            _fzf_comprun() {
                local cmd=$1
                shift
                case $cmd in
                    *) fzf "$@";;
                esac
            }
            # fzf completion for functions
            _fzf_complete_functions() _fzf_complete -- "$@" < <(print ${(kF)functions})
        fi
    }
fi

# Editing
#########

# Copy the current buffer into the system clipboard so that you can paste with ctrl-v
copy-to-system-clipboard () {
    print -rn -- $BUFFER | xclip -selection clipboard
}

zle -N copy-to-system-clipboard
bindkey '\C-x\C-y' copy-to-system-clipboard

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# file rename magic
bindkey "^[m" copy-prev-shell-word

# Use Esc-s (or Alt-s) to switch git branches
bindkey -s '\es' 'gh switch-branch\n'
