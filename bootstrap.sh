#!/bin/bash

# strict mode
set -euo pipefail

BRANCH="${1:-}"

REQUIRED_PKGS=(
    build-essential
    ca-certificates
    curl
    fontconfig
    git
    ripgrep
    stow
    unzip
    wget
    xz-utils
    zsh
)

missing_pkgs=()
for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! dpkg -s "$pkg" &> /dev/null; then
        missing_pkgs+=("$pkg")
    fi
done

if (( ${#missing_pkgs[@]} > 0 )); then
    echo "🔧 installing missing packages: ${missing_pkgs[*]}"
    sudo apt-get update
    sudo apt-get install --no-install-recommends -y "${missing_pkgs[@]}"
    echo "✅ packages installed"
else
    echo "✅ all required packages already installed"
fi

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# mise
(
    if command -v mise > /dev/null; then
        echo "✅ mise already installed"
        exit 0
    fi
    echo "🔧 installing mise"
    curl https://mise.run | sh
    echo "✅ mise installed"
)

# dotfiles
if [ ! -d ~/.dotfiles ]; then
    echo "🔧 cloning dotfiles"
    clone_args=(--recurse-submodules)
    if [[ -n "$BRANCH" ]]; then
        clone_args+=(--branch "$BRANCH")
    fi
    set -x
    git clone "${clone_args[@]}" https://github.com/duboisf/.dotfiles.git ~/.dotfiles
    set +x
    echo "✅ dotfiles cloned"
else
    echo "🔧 updating submodules"
    git -C ~/.dotfiles submodule update --init --recursive
fi

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

# stow dotfiles
(
    cd ~/.dotfiles \
    && stow \
       gh \
       git \
       kitty \
       mise \
       nushell \
       nvim \
       scripts \
       starship \
       zsh
)

# Install all tools defined in ~/.config/mise/config.toml
echo "🔧 installing mise tools"
~/.local/bin/mise install
echo "✅ mise tools installed"

echo "🎉 bootstrap complete! Please restart your terminal to apply changes."
