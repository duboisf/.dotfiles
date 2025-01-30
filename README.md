# .dotfiles

My personal dotfiles.

# Installation

```bash
cd ~
# This repo contains git submodules, so you need the --recursive option
git clone --recursive https://github.com/duboisf/.dotfiles.git
cd .dotfiles
stow zsh
stow nvim
# etc.
```

## Install github's cli, gh

```bash
curl -L -o /tmp/gh.deb https://github.com/cli/cli/releases/download/v2.65.0/gh_2.65.0_linux_amd64.deb && sudo dpkg -i /tmp/gh.deb
```

## Install nerdfonts

These fonts are needed to render the terminal and nvim correctly:

```bash
cd ~/Downloads
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaMono.tar.xz
mkdir ~/.fonts
cd ~/.fonts
tar xf ~/Downloads/CascadiaMono.tar.xz
fc-cache -fv
```

## Install nvim

Download nightly build from [here](https://github.com/neovim/neovim/releases/nightly) and then:

```bash
mkdir -p ~/.local/stow
cd ~/.local/stow
curl -LO https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux64.tar.gz
tar xf nvim-linux64.tar.gz
stow nvim-linux64
```

## Install kitty

```bash
mkdir ~/.local/stow
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
  dest=~/.local/stow
cd ~/.local/stow
stow -v kitty.app
sudo ln -s /home/fred/.local/bin/kitty /usr/local/bin/kitty
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/kitty 100
```

## Install keybase

```bash
curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
sudo apt install ./keybase_amd64.deb
run_keybase
```

### Import keybase pgp key into gpg

```bash
keybase pgp export | gpg --import
keybase pgp export --secret | gpg --import --allow-secret-key-import
```

# Setup

## Fix gnome-shell overview shortcut for Kinesis Advantage2 keyboard

My Kinesis Advantage2 keyboard's Super (windows) key doesn't trigger the Gnome Shell Overview by default. This is because the Super key on the keyboard is actually a _right_ Super key. We can fix this by installing gnome-tweaks (`sudo apt install gnome-tweaks`) and picking the _right_ Super key as the _Overview Shortcut_ in the `Keyboard & Mouse` section.

