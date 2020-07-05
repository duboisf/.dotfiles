
path=(
  ~/.local/bin
  /snap/bin
  ~/go/bin
  /usr/local/go/bin
  $path
)

export MANPAGER='nvim --cmd "let g:pager_mode = 1" +Man!'
export MANWIDTH=999
export EDITOR=nvim
export GPG_TTY=$(tty)
export NVM_DIR=~/.nvm
