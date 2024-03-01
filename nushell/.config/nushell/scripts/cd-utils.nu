export def --env fzf []: nothing -> nothing {
  let picked_dir = fd --type d | ^fzf | to text
  if $picked_dir != null {
    cd $picked_dir
  }
}
