export VOLTA_HOME="$HOME/.volta"

path=(
  $VOLTA_HOME/bin
  ~/.krew/bin
  ~/.local/bin
  /snap/bin
  ~/go/bin
  /usr/local/go/bin
  ~/.pulumi/bin
  ~/.poetry/bin
  $path
)

if [[ -d ~/.tfenv/bin ]]; then
    path=(~/.tfenv/bin $path)
fi

export DOCKER_BUILDKIT=1
export EDITOR=nvim
export GPG_TTY=$(tty)
export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
export MANWIDTH=999
export NVM_DIR=~/.nvm
export ZK_NOTEBOOK_DIR=~/notes

if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    if [[ -f ~/.config/gh/hosts.yml ]]; then
        export HOMEBREW_GITHUB_API_TOKEN=$(perl -wlne '/oauth_token: (.*)/ and print $1' ~/.config/gh/hosts.yml)
    else
        echo "brew is installed but we can't define HOMEBREW_GITHUB_API_TOKEN since gh isn't installed, or auth hasn't been setup yet (~/.config/gh/hosts.yml)" >&2
    fi
fi

export BAT_THEME='Solarized (dark)'
