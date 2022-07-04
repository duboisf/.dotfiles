vim.filetype.add({
  pattern = {
    -- when editing the current command line in vim from zsh by doing ctrl-x,
    -- ctrl-e, set the filetype as bash. This is just to get treesitter to
    -- highlight the file with the bash parser because there is no zsh parser
    -- currently.
    ["/tmp/zsh.*"] = "bash",
  }
})
