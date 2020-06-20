# Completion
############
# Don't autocomplete . and .., this is set in oh-by-zsh/lib/completion.zsh
zstyle ':completion:*' special-dirs false

# Directory navigation lifehacks
################################
#
# Use Esc-l (or Alt-l) to list directory content
bindkey -s '\el' 'l\n'
# Use Esc+u (or Alt+u) to go up to the parent folder
bindkey -s '\eu' 'cd ..\n'

# Every time we change directories record it in the recently
# visited directories list
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 1000
# Bind [Esc-j] (or Alt-j) to fuzzy find a semi-recently visited folder
bindkey -s '\ej' "cdr \$(cdr -l | egrep -v ' ~$' | fzf --with-nth=2 | awk '{print \$1}')\n"

