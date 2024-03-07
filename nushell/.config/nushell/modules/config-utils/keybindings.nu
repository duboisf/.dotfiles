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
    | fzf --read0 --tiebreak=index --preview="echo Command:\\n; echo {} | nu -n --stdin -c nu-highlight" --preview-window=up:50%:wrap

    if $picked_entry != "" {
      commandline edit --insert $picked_entry
    }
  }
}

export def main []: nothing -> list<any> {
  [
    {
        name: sonder_config_kubectl
        modifier: alt
        keycode: char_k
        mode: emacs
        event: [
            {
                send: executehostcommand,
                cmd: "sonder config kubectl"
            }
        ]
    }
    {
        name: sonder_config_kubectl
        modifier: alt
        keycode: char_n
        mode: emacs
        event: [
            {
                send: executehostcommand,
                cmd: "sonder config kubectl --namespace"
            }
        ]
    }
    {
        name: git_switch_branch
        modifier: alt
        keycode: char_s
        mode: emacs
        event: [
            {
                send: executehostcommand,
                cmd: "gh switch-branch"
            }
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
                cmd: 'use config-utils keybindings *; insert-last-word'
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
                cmd: 'use config-utils keybindings *; append-pipe-grep'
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
                cmd: 'use config-utils keybindings *; cd-fzf'
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
                cmd: 'use config-utils keybindings *; explore-last-result'
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
          cmd: 'use config-utils keybindings *; history-fzf'
        }
    }
  ]
}
