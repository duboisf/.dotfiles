export ZPLUG_LOG_LOAD_FAILURE=true
source ~/.zplug/init.zsh

# Commands
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf
zplug "stedolan/jq", from:gh-r, as:command, rename-to:jq
zplug "kubernetes/minikube", from:gh-r, as:command
# Lazy load nvm, see .zsh/lib/nvm.zsh
zplug "nvm-sh/nvm", use:"nvm.sh", as:command, rename-to:__init_nvm
zplug "ogham/exa", from:gh-r, as:command, at:v0.9.0

# Plugins
# Add fzf completion and key bindings. Need to execute after compinit, so defer
zplug "junegunn/fzf", use:"shell/*.zsh", defer:2
# Add exa completion, use my fork because zplug doesn't work when
# trying to use gh-r and plugin from the same repo (it doesn't
# clone the repo when using gh-r). To load completion, I just symlinked the
# completion file `zsh/.zsh/completions/_exa` to the
# `$ZPLUG_REPOS/duboisf/exa/contrib/completions.zsh`
zplug "duboisf/exa", at:v0.9.0
# Reuse oh-my-zsh configs that I'm used to
zplug "lib/completion", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
# Nice syntax highlighting like fish, need to run after compinit (defer:2)
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Theme
zplug "duboisf/fred.zsh-theme", as:theme

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Update fpath to include local completions.
# Need to do this before zplug load as it calls compinit
fpath=(~/.zsh/completions $fpath)

zplug load

# Load local config
for file in ~/.zsh/lib/*.zsh; do
    source $file
done
