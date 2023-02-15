
if (( $+commands[aws] )); then
    autoload -U +X bashcompinit && bashcompinit
    complete -C =aws_completer aws
fi

if (( $+commands[terraform] )); then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C =terraform terraform
fi
