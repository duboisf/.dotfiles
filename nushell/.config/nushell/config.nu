do { ||
  use std log
  const supported_version = '0.100.0'
  if (nu --version) < $supported_version {
    log warning $"This config is designed for nushell ($supported_version) or later."  
  }
}

# source ~/.config/nushell/config-default.nu

do --env { ||
 mut c = $env.config
 $c.show_banner = false
 $c.history.file_format = "sqlite"
 $c.history.isolation = true
 $c.completions.algorithm = "fuzzy"
 $c.filesize.unit = "metric"
 $c.cursor_shape.emacs = "block"
 # $c.color_config = $light_theme # if you want a more interesting theme, you can replace the empty record with `$dark_theme`, `$light_theme` or another custom record
 $c.footer_mode = 25 # always, never, number_of_rows, auto
 $c.use_kitty_protocol = true # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.
 $c.highlight_resolved_externals = true # true enables highlighting of external commands in the repl resolved by which.
 $c.keybindings = $c.keybindings ++ (do {
   use ~/.config/nushell/modules/config-utils
   config-utils keybindings
 })
 $env.config = $c
}

# Open nvim in my dotfiles directory
def edot []: nothing -> nothing {
   cd ~/.dotfiles
   nvim
}

source ~/.config/nushell/aliases.nu
# use ~/.config/nushell/modules/waws
use ~/.config/nushell/modules/kubectl.nu *
use ~/.config/nushell/modules/utils.nu *
use ~/.config/nushell/modules/cf

let cache_dir = ($env.HOME | path join ".cache" "starship")
let starship_init = ($cache_dir | path join "init.nu")

if not ($cache_dir | path exists) {
  mkdir $cache_dir
}

if not ($starship_init | path exists) {
  starship init nu | save -f $starship_init
}

if (which starship | is-not-empty) {
  $env.STARSHIP_SHELL = "nu"
  $env.STARSHIP_SESSION_KEY = (random chars -l 16)
  $env.PROMPT_MULTILINE_INDICATOR = (^starship prompt --continuation)
  $env.PROMPT_INDICATOR = ""

  $env.config = ($env.config? | default {} | merge {
    render_right_prompt_on_last_line: true
  })

  $env.PROMPT_COMMAND = {||
    let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS }

    (
      ^starship prompt
        --cmd-duration $cmd_duration
        $"--status=($env.LAST_EXIT_CODE)"
        --terminal-width (term size).columns
        ...(
          if (which "job list" | where type == built-in | is-not-empty) {
            ["--jobs", (job list | length)]
          } else {
            []
          }
        )
    )
  }

  $env.PROMPT_COMMAND_RIGHT = {||
    let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS }

    (
      ^starship prompt
        --right
        --cmd-duration $cmd_duration
        $"--status=($env.LAST_EXIT_CODE)"
        --terminal-width (term size).columns
        ...(
          if (which "job list" | where type == built-in | is-not-empty) {
            ["--jobs", (job list | length)]
          } else {
            []
          }
        )
    )
  }
}

# source ~/.cache/carapace/init.nu
