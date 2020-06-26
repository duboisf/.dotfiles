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
    if (( $force_chpwd_recent_dirs == 0 ))
    then
        if [[ ! -o interactive || $ZSH_SUBSHELL -ne 0 || ( -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT != toplevel(:[a-z]#func|)# ) ]]
        then
            return
        fi
    fi
	chpwd_recent_filehandler
	if [[ $reply[1] != $PWD ]]
	then
		chpwd_recent_add $PWD && changed=1 
		(( changed )) && chpwd_recent_filehandler $reply
	fi
    force_chpwd_recent_dirs=0
}

autoload -Uz cdr add-zsh-hook
add-zsh-hook chpwd custom_chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 1000
# Don't record ~ and /, kinda useless to do so
zstyle ':chpwd:*' recent-dirs-prune pattern:"$HOME$" pattern:'^/$'

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

# fzf config
############

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
            typeset -g FZF_ALT_C_COMMAND
            typeset -g FZF_CTRL_T_COMMAND
            typeset -g FZF_DEFAULT_COMMAND
            # By default fzf uses find, let's use fd instead
            FZF_DEFAULT_COMMAND="$fd_bin_path --type f --hidden"
            FZF_CTRL_T_COMMAND="$fd_bin_path --type f --hidden --no-ignore-vcs"
            FZF_ALT_C_COMMAND="$fd_bin_path --type d --hidden --no-ignore-vcs"
        fi
    }
fi

# Editing
#########

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# file rename magic
bindkey "^[m" copy-prev-shell-word
