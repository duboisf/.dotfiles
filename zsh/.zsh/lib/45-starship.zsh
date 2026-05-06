# Auto-select starship palette based on the kitty terminal background and
# re-check on each prompt so it follows kitty's auto-theme switching.
# Generates a starship.toml copy with the palette injected and points
# STARSHIP_CONFIG at it. Override by exporting STARSHIP_PALETTE.

(( ${+commands[starship]} )) || return

_starship_palette_for_bg() {
    # $1 is a hex color like "#282c34"; print "bluloco_light" or "bluloco_dark"
    local bg=$1
    [[ $bg == \#[0-9a-fA-F]* && ${#bg} -ge 7 ]] || return 1
    local r=$((16#${bg:1:2}))
    local g=$((16#${bg:3:2}))
    local b=$((16#${bg:5:2}))
    if (( (r * 299 + g * 587 + b * 114) / 1000 > 128 )); then
        print bluloco_light
    else
        print bluloco_dark
    fi
}

_starship_sync_palette() {
    local src=${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml
    [[ -r $src ]] || return

    local palette=$STARSHIP_PALETTE
    if [[ -z $palette && -n $KITTY_PID ]] && (( ${+commands[kitty]} )); then
        local bg=$(timeout 0.5 kitty @ get-colors 2>/dev/null \
            | awk '$1 == "background" { print $2; exit }')
        palette=$(_starship_palette_for_bg "$bg")
    fi
    : ${palette:=bluloco_light}

    [[ $palette == $_starship_active_palette && -n $STARSHIP_CONFIG ]] && return
    _starship_active_palette=$palette

    local cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/starship
    local dst=$cache_dir/$palette.toml
    if [[ ! -f $dst || $src -nt $dst ]]; then
        mkdir -p $cache_dir
        sed "s/^palette = .*/palette = '$palette'/" $src > $dst
    fi
    export STARSHIP_CONFIG=$dst
}

# Initial sync at shell load
_starship_sync_palette

# Re-check on each prompt (throttled) so theme follows kitty's auto-switching
typeset -g _starship_last_check=0
_starship_palette_precmd() {
    (( SECONDS - _starship_last_check < 2 )) && return
    _starship_last_check=$SECONDS
    _starship_sync_palette
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _starship_palette_precmd
