FROM ubuntu

RUN apt update \
 && apt install -y \
    build-essential \
    curl \
    git \
    wget

RUN curl https://get.volta.sh | bash \
 # was updated by volta installer, need to source
 && . ~/.bashrc \
 && volta install node

RUN wget https://github.com/neovim/neovim/releases/download/v0.7.2/nvim-linux64.deb \
 && apt install ./nvim-linux64.deb

WORKDIR /root

COPY . ./.config/nvim
