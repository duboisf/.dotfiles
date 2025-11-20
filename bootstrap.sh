#!/bin/bash

# strict mode
set -euo pipefail

sudo apt-get update

sudo apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    curl \
    eza \
    fontconfig \
    git \
    ripgrep \
    stow \
    wget \
    xz-utils \
    zsh

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# golang
(
    if command -v go > /dev/null; then
        echo "✅ golang already installed"
        exit 0
    fi
    cd $TMPDIR
    curl -L -o golang.tar.gz https://go.dev/dl/go1.25.4.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf golang.tar.gz
)

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

# Caskaydia font
(
    if (( $(find ~/.fonts -name 'Caskaydia*' 2> /dev/null | wc -l) > 0 )); then
        echo "✅ Caskaydia font already installed"
        exit 0
    fi
    echo "🔧 installing Caskaydia font"
    cd $TMPDIR
    curl -L -o cascadia.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip
    mkdir ~/.fonts 2> /dev/null || true
    cd ~/.fonts
    unzip $TMPDIR/cascadia.tar.xz
    fc-cache -fv
    echo "✅ Caskaydia font installed"
)

# Symbols font
(
    if (( $(find ~/.fonts -name 'SymbolsNerd*' 2> /dev/null | wc -l) > 0 )); then
        echo "✅ Symbols Nerd Font already installed"
        exit 0
    fi
    echo "🔧 installing Symbols Nerd Font"
    cd $TMPDIR
    curl -L -o symbols.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/NerdFontsSymbolsOnly.tar.xz
    mkdir ~/.fonts 2> /dev/null || true
    cd ~/.fonts
    tar xf $TMPDIR/symbols.tar.xz
    fc-cache -fv
    echo "✅ Symbols Nerd Font installed"
)


# nvim
(
    if [[ -x ~/.local/bin/nvim ]]; then
        echo "✅ nvim already installed"
        exit 0
    fi
    echo "🔧 installing nvim"
    cd $TMPDIR
    curl -L -o nvim.tar.gz https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz
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
    curl -L -o starship.tar.gz https://github.com/starship/starship/releases/download/v1.24.0/starship-x86_64-unknown-linux-gnu.tar.gz
    tar xf starship.tar.gz
    install ./starship ~/.local/bin
    echo "✅ starship installed"
)

# fzf
(
    if [[ -x ~/.local/bin/fzf ]]; then
        echo "✅ fzf already installed"
        exit 0
    fi
    echo "🔧 installing fzf"
    cd $TMPDIR
    curl -L -o fzf.tar.gz https://github.com/junegunn/fzf/releases/download/v0.66.1/fzf-0.66.1-linux_amd64.tar.gz
    tar xf fzf.tar.gz
    install ./fzf ~/.local/bin
    echo "✅ fzf installed"
)

# fd
(
    if [[ -x ~/.local/bin/fd ]]; then
        echo "✅ fd already installed"
        exit 0
    fi
    echo "🔧 installing fd"
    cd $TMPDIR
    curl -L -o fd.tar.gz https://github.com/sharkdp/fd/releases/download/v10.3.0/fd-v10.3.0-x86_64-unknown-linux-gnu.tar.gz
    tar xf fd.tar.gz
    find | grep fd
    install ./fd-*/fd ~/.local/bin
    echo "✅ fd installed"
)

# volta
(
    if [[ -x ~/.volta/bin/volta ]]; then
        echo "✅ volta already installed"
        exit 0
    fi
    echo "🔧 installing volta"
    curl curl https://get.volta.sh | bash
    # install latest lts node
    ~/.volta/bin/volta install node
    echo "✅ volta installed"
)

# dotfiles
(
    cd
    if [ ! -d ~/.dotfiles ]; then
        # This should already be clone but 🤷
        echo "🔧 cloning dotfiles"
        git clone --recursive https://github.com/duboisf/.dotfiles.git
        echo "✅ dotfiles cloned"
    fi
    cd ~/.dotfiles
    git submodule update --init --recursive
    echo "🔧 stowing various dotfiles"
    stow gh git kitty nushell nvim starship zsh
    echo "✅ dotfiles stowed"
)

echo "ℹ There are other zsh functions to bootstrap other tools,"
echo "  they start with 'duboisf-bootstrap-*'"
echo "All done! You might need to log out and log back in for some changes to take effect."
