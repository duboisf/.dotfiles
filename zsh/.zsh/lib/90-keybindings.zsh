
zle -N change-git-worktree-dir-widget
bindkey '\ew' change-git-worktree-dir-widget

# Use Esc-l (or Alt-l) to list directory content
bindkey -s '\el' 'l\n'

# Bind Esc+u (or Alt+u) to go up to the parent folder
zle -N cd-to-parent-directory-widget
bindkey '\eu' cd-to-parent-directory-widget

# define the cdr-widget
zle -N cdr-widget
# bind alt-j to the cdr-widget
bindkey '\ej' cdr-widget

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
