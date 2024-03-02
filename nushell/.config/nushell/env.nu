source ~/.config/nushell/env-default.nu

$env.TRANSIENT_PROMPT_COMMAND = {|| $"\n(starship  module time)🚀 " }

mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
