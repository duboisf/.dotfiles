if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    if [[ -f ~/.config/gh/hosts.yml ]]; then
        export HOMEBREW_GITHUB_API_TOKEN=$(perl -wlne '/oauth_token: (.*)/ and print $1' ~/.config/gh/hosts.yml)
    else
        echo "brew is installed but we can't define HOMEBREW_GITHUB_API_TOKEN since gh isn't installed, or auth hasn't been setup yet (~/.config/gh/hosts.yml)" >&2
    fi
fi

export BAT_THEME='Solarized (dark)'
