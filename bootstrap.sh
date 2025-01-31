#!/bin/bash

# strict mode
set -euo pipefail

sudo apt-get update

sudo apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    fontconfig \
    git \
    stow \
    wget \
    xz-utils \
    zsh

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# gh
(
    if command -v gh > /dev/null; then
        echo "✅ gh already installed"
        exit 0
    fi
    echo "🔧 installing gh"
    cd $TMPDIR
    curl -L -o gh.deb https://github.com/cli/cli/releases/download/v2.65.0/gh_2.65.0_linux_amd64.deb
    sudo dpkg -i gh.deb
    echo "✅ gh installed"
)

# font
(
    if (( $(find ~/.fonts -name 'Caskaydia*' 2> /dev/null | wc -l) > 0 )); then
        echo "✅ Caskaydia font already installed"
        exit 0
    fi
    echo "🔧 installing Caskaydia font"
    cd $TMPDIR
    curl -L -o fonts.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaMono.tar.xz
    mkdir ~/.fonts 2> /dev/null || true
    cd ~/.fonts
    tar xf $TMPDIR/fonts.tar.xz
    fc-cache -fv
    echo "✅ Caskaydia font installed"
)

# nvim
(
    if [[ -x ~/.local/bin/nvim ]]; then
        echo "✅ nvim already installed"
        exit 0
    fi
    echo "🔧 installing nvim"
    cd $TMPDIR
    curl -L -o nvim.tar.gz https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
    mkdir -p ~/.local/stow 2> /dev/null || true
    cd ~/.local/stow
    tar xf $TMPDIR/nvim.tar.gz
    stow nvim*
    echo "✅ nvim installed"
)

# kitty
(
    if [[ -x ~/.local/bin/kitty ]]; then
        echo "✅ kitty already installed"
        exit 0
    fi
    echo "🔧 installing kitty"
    mkdir -p ~/.local/stow 2> /dev/null || true
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin dest=~/.local/stow
    cd ~/.local/stow
    stow kitty.app
    sudo ln -s ~/.local/bin/kitty /usr/local/bin/kitty
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/kitty 100
    echo "✅ kitty installed"
)

# starship
(
    if [[ -x ~/.local/bin/starship ]]; then
        echo "✅ starship already installed"
        exit 0
    fi
    echo "🔧 installing starship"
    cd $TMPDIR
    curl -L -o starship.tar.gz https://github.com/starship/starship/releases/download/v1.22.1/starship-x86_64-unknown-linux-gnu.tar.gz
    tar xf starship.tar.gz
    install ./starship ~/.local/bin
    echo "✅ starship installed"
)

# dotfiles
(
    if [[ ! -d ~/.dotfiles ]]; then
        # This should already be clone but 🤷
        echo "🔧 cloning dotfiles"
        exit 0
    fi
    echo "🔧 update dotfiles git submodules"
    cd ~/.dotfiles
    git submodule update --init --recursive
    echo "✅ dotfiles git submodules updated"
)
