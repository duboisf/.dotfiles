source ~/.config/nushell/config-default.nu

mut config = $env.config
$config.show_banner = false
$config.history.file_format = "sqlite"
$config.history.isolation = true
$config.completions.algorithm = "fuzzy"
$config.filesize.metric = true
$config.cursor_shape.emacs = "block"
$config.color_config = $light_theme # if you want a more interesting theme, you can replace the empty record with `$dark_theme`, `$light_theme` or another custom record
$config.footer_mode = 15 # always, never, number_of_rows, auto
$config.shell_integration = true # enables terminal shell integration. Off by default, as some terminals have issues with this.
$config.use_kitty_protocol = true # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.
$config.highlight_resolved_externals = true # true enables highlighting of external commands in the repl resolved by which.
$config.keybindings = $config.keybindings ++ [
  {
      name: sonder_config_kubectl
      modifier: alt
      keycode: char_k
      mode: emacs
      event: [
          { edit: Clear }
          {
              edit: InsertString,
              value: "sonder config kubectl"
          }
          { send: Enter }
      ]
  }
  {
      name: sonder_config_kubectl
      modifier: alt
      keycode: char_n
      mode: emacs
      event: [
          { edit: Clear }
          {
              edit: InsertString,
              value: "sonder config kubectl --namespace"
          }
          { send: Enter }
      ]
  }
  {
      name: git_switch_branch
      modifier: alt
      keycode: char_s
      mode: emacs
      event: [
          { edit: Clear }
          {
              edit: InsertString,
              value: "gh switch-branch"
          }
          { send: Enter }
      ]
  }
  {
      name: insert_last_word
      modifier: alt
      keycode: char_.
      mode: emacs
      event: [
          {
              send: executehostcommand,
              cmd: 'use keybinding-utils *; insert-last-word'
          }
      ]
  }
  {
      name: cd_dot_dot
      modifier: alt
      keycode: char_u
      mode: emacs
      event: [
          {
              send: executehostcommand,
              cmd: 'cd ..'
          }
      ]
  }
  {
      name: append_pipe_grep
      modifier: control
      keycode: char_i
      mode: emacs
      event: [
          {
              send: executehostcommand,
              cmd: 'use keybinding-utils *; append-pipe-grep'
          }
      ]
  }
  {
      name: fzf_cd
      modifier: alt
      keycode: char_c
      mode: emacs
      event: [
          {
              send: executehostcommand,
              cmd: 'use keybinding-utils *; cd-fzf'
          }
      ]
  }
  {
      name: explore_last_result
      modifier: alt
      keycode: char_e
      mode: emacs
      event: [
          {
              send: executehostcommand,
              cmd: 'use keybinding-utils *; explore-last-result'
          }
      ]
  }
  {
      name: history_menu
      modifier: control
      keycode: char_r
      mode: [emacs, vi_insert, vi_normal]
      event: {
        send: executehostcommand,
        cmd: 'use keybinding-utils *; history-fzf'
      }
  }
]

$env.config = $config

# Module that defines commands only used in keybindings
module keybinding-utils {

  export def append-pipe-grep []: nothing -> nothing {
    commandline edit --append "| grep "
    commandline set-cursor --end
  }

  export def --env cd-fzf []: nothing -> nothing {
    let picked_dir = fd --type d | ^fzf | to text
    if $picked_dir != null {
      cd $picked_dir
    }
  }

  export def explore-last-result []: nothing -> nothing {
    let last_command = history | last | get command
    commandline edit $"let ans = ($last_command); $ans | explore"
  }

  export def insert-last-word [] {
    let last_word = history | last | get command | split row --regex '\s+' | last
    commandline edit --append $last_word
    commandline set-cursor --end
  }

  export def history-fzf []: nothing -> nothing {
    if $env.config.history.file_format == sqlite {
      let picked_entry = open ~/.config/nushell/history.sqlite3
      | query db `
          SELECT max(id) as id, command_line
          FROM history
          WHERE duration_ms IS NOT NULL
          GROUP BY command_line
          ORDER BY id DESC
      `
      | get command_line
      | str join (char -i 0)
      | fzf --read0 --tiebreak=index --preview="echo Command:\\n; tree-sitter highlight --scope=source.nu <(echo {})" --preview-window=up:50%:wrap

      if $picked_entry != "" {
        commandline edit $picked_entry
      }
    }
  }

}

# Open nvim in my dotfiles directory
def edot []: nothing -> nothing {
    cd ~/.dotfiles
    nvim
}

use ~/.config/nushell/scripts/aliases.nu *
use ~/.config/nushell/scripts/aws *
use ~/.config/nushell/scripts/kubectl.nu *
use ~/.config/nushell/scripts/private.nu *
use ~/.config/nushell/scripts/pulumi.nu *
use ~/.config/nushell/scripts/utils.nu *

source ~/.cache/carapace/init.nu
use ~/.cache/starship/init.nu
