use utils.nu notify

export def "status" []: nothing -> string {
  warp-cli status | lines | parse "Status update: {status}" | get status.0
}

export def "toggle" []: nothing -> string {
  let current_status = status
  if (status) == Connected {
    warp-cli disconnect | notify "Warp" "Disconnected"
  } else {
    warp-cli connect | notify "Warp" "Connected"
  }
}

toggle
