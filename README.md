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
