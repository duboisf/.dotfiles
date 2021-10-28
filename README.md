# .dotfiles

My personal dotfiles.

# Installation

```sh
cd ~
# This repo contains git submodules, so you need the --recursive option
git clone --recursive https://github.com/duboisf/.dotfiles.git
cd .dotfiles
stow zsh
stow nvim
# etc.
```

## Install github's hub

GitHub's `hub` is an alias for `git` in my zsh config. It makes cloning repos from GitHub a breeze, among other things. Install with:

```sh
sudo apt install hub
```

## Install nerdfonts

These fonts are needed to render the terminal and nvim correctly:

```sh
cd ~/Downloads
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
mkdir ~/.fonts
cd ~/.fonts
unzip ~/Downloads/{FiraCode,JetBrainsMono}.zip
fc-cache -fv
```

## Install nvm

nvm stands for Node Version Manager. Node is used by nvim's coc plugin. To install nvm, run:

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash
```

## Install nvim

Download nightly build from [here](https://github.com/neovim/neovim/releases/nightly) and then:

```sh
cd ~/Downloads
chmod +x ./nvim.appimage
./nvim.appimage --appimage-extract
mv squashfs-root/ ~/.local/nvim
mkdir ~/.local/bin
ln -s ~/.local/nvim/AppRun ~/.local/bin/nvim
```

### Setup nvim dependencies

To get all the nvim plugins working properly we need to install python and node:

```sh
sudo apt install python3-pip
pip3 install pynvim
```

We also need to install some binaries like [bat](https://github.com/sharkdp/bat/releases), rg (`sudo apt install ripgrep`) and [fd](https://github.com/sharkdp/fd/releases).

## Install kitty

```sh
mkdir ~/.local/stow
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
  dest=~/.local/stow
cd ~/.local/stow
stow -v kitty.app
sudo ln -s /home/fred/.local/bin/kitty /usr/local/bin/kitty
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/kitty 100
```

## Install keybase

```sh
curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
sudo apt install ./keybase_amd64.deb
run_keybase
```

### Import keybase pgp key into gpg

```
keybase pgp export | gpg --import
keybase pgp export --secret | gpg --import --allow-secret-key-import
```

# Setup

## Fix gnome-shell overview shortcut for Kinesis Advantage2 keyboard

My Kinesis Advantage2 keyboard's Super (windows) key doesn't trigger the Gnome Shell Overview by default. This is because the Super key on the keyboard is actually a _right_ Super key. We can fix this by installing gnome-tweaks (`sudo apt install gnome-tweaks`) and picking the _right_ Super key as the _Overview Shortcut_ in the `Keyboard & Mouse` section.

