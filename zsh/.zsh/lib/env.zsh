
path=(
  ~/.local/bin
  /snap/bin
  ~/go/bin
  /usr/local/go/bin
  $path
)

if [[ -d ~/.tfenv/bin ]]; then
    path=(~/.tfenv/bin $path)
fi

export DOCKER_BUILDKIT=1
export EDITOR=nvim
export GPG_TTY=$(tty)
export MANPAGER='nvim --cmd "let g:pager_mode = 1" +Man!'
export MANWIDTH=999
export NVM_DIR=~/.nvm
