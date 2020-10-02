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
# This repo is huge, takes time to clone even with depth=1
git clone --depth=1 ryanoasis/nerd-fonts
cd nerd-fonts
./install.sh
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

## Install kitty

```sh
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
sudo ln -s /home/fred/.local/kitty.app/bin/kitty /usr/local/bin/kitty
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
