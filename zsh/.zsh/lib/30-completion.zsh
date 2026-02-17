# Completion system setup (inlined from oh-my-zsh lib/completion)
zmodload -i zsh/complist

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

# Navigate completion menu
bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

# Case-insensitive, partial-word, and substring completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

# Don't autocomplete . and ..
zstyle ':completion:*' special-dirs false

# Kill process completion colors
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

# cd: prefer local directories over stack
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Completion caching
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache

# Don't complete uninteresting system users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'
zstyle '*' single-ignored show

# Makefile completion: show only targets, not files and targets
zstyle ':completion:*:*:make:*' tag-order 'targets'

# Register custom git subcommands for completion
zstyle ':completion:*:*:git:*' user-commands merge-worktree:'merge worktree branch and remove worktree'

# Load bashcompinit once for all bash-style completions below
if (( $+commands[aws] || $+commands[terraform] || $+commands[gcloud] )); then
    autoload -U +X bashcompinit && bashcompinit
fi

if (( $+commands[aws] )); then
    complete -C =aws_completer aws
fi

if (( $+commands[terraform] )); then
    complete -o nospace -C =terraform terraform
fi

# gcloud completion (derive SDK root from binary path; works with mise, apt, manual installs)
if (( $+commands[gcloud] )); then
  local sdk_root="${commands[gcloud]:A:h:h}"

  if [[ -f "${sdk_root}/completion.zsh.inc" ]]; then
    source "${sdk_root}/completion.zsh.inc"
  elif [[ -f "${sdk_root}/completion.bash.inc" ]]; then
    source "${sdk_root}/completion.bash.inc"
  fi
fi
