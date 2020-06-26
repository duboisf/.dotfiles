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
    local ret=$?
    zle redraw-prompt
    return $ret
}
zle -N cd-to-parent-directory-widget
# Bind Esc+u (or Alt+u) to go up to the parent folder
bindkey '\eu' cd-to-parent-directory-widget

# Push to the directory stack on directory change
setopt autopushd

# Every time we change directories record it in the recently
# visited directories list
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 1000
# Don't record ~ and /, kinda useless to do so
zstyle ':chpwd:*' recent-dirs-prune 'pattern:~' 'pattern:/'

# fuzzy find a semi-recently visited folder
cdr-widget() {
    setopt localoptions pipefail
    local dir="$(cdr -l \
        | fzf --height='20%' --layout=reverse --info=hidden --header="Recently visited directories" --with-nth=2 \
        | awk '{print $1}')"
    if [[ -z $dir ]]; then
        zle redisplay
        return 0
    fi
    cdr $dir > /dev/null 2>&1
    local ret=$?
    zle fzf-redraw-prompt
    return $ret
}
# define the cdr-widget
zle -N cdr-widget
# bind alt-j to the cdr-widget
bindkey '\ej' cdr-widget

# fzf config
############

() {
    if (( $+commands[fzf] )); then
        # In debian based distributions, the fd binary is named fdfind
        local fd_bin_path=${commands[fd]:-$commands[fdfind]}
        if [[ -n $fd_bin_path ]]; then
            typeset -g FZF_ALT_C_COMMAND
            typeset -g FZF_CTRL_T_COMMAND
            typeset -g FZF_DEFAULT_COMMAND
            # By default fzf uses find, let's use fd instead
            FZF_DEFAULT_COMMAND="$fd_bin_path --type f --hidden"
            FZF_CTRL_T_COMMAND="$fd_bin_path --type f --hidden --no-ignore-vcs"
            FZF_ALT_C_COMMAND="$fd_bin_path --type d --hidden --no-ignore-vcs"
        fi
    fi
}

# Editing
#########

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# file rename magic
bindkey "^[m" copy-prev-shell-word
