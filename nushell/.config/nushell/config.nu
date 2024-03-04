do { ||
  use std log
  const supported_version = '0.90.2'
  if (nu --version) < $supported_version {
    log warning $"This config is designed for nushell ($supported_version) or later."  
  }
}

source ~/.config/nushell/config-default.nu

do --env { ||
  mut c = $env.config
  $c.show_banner = false
  $c.history.file_format = "sqlite"
  $c.history.isolation = true
  $c.completions.algorithm = "fuzzy"
  $c.filesize.metric = true
  $c.cursor_shape.emacs = "block"
  $c.color_config = $light_theme # if you want a more interesting theme, you can replace the empty record with `$dark_theme`, `$light_theme` or another custom record
  $c.footer_mode = "always" # always, never, number_of_rows, auto
  $c.shell_integration = true # enables terminal shell integration. Off by default, as some terminals have issues with this.
  $c.use_kitty_protocol = true # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.
  $c.highlight_resolved_externals = true # true enables highlighting of external commands in the repl resolved by which.
  $c.keybindings = $c.keybindings ++ (do {||
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

source ([$nu.default-config-dir aliases.nu] | path join)
use ~/.config/nushell/modules/aws *
use ~/.config/nushell/modules/kubectl.nu *
use ~/.config/nushell/modules/private.nu *
use ~/.config/nushell/modules/pulumi.nu *
use ~/.config/nushell/modules/utils.nu *

source ~/.cache/carapace/init.nu
use ~/.cache/starship/init.nu
