vim.filetype.add({
  extension = {
    -- Theres a bug currently where tfvars files get assigned the
    -- terraform-vars filetype and you get a bunch of errors like this:
    --   E5248: Invalid character in group name
    -- The "fix" is to just set the filetype to terraform.
    tfvars = "terraform"
  },
  pattern = {
    -- when editing the current command line in vim from zsh by doing ctrl-x,
    -- ctrl-e, set the filetype as bash. This is just to get treesitter to
    -- highlight the file with the bash parser because there is no zsh parser
    -- currently.
    ['/tmp/zsh.*'] = 'bash',
    -- I use these paths for helm charts
    ['.*/charts/.*/templates/.*%.yaml'] = 'gotmpl',
    ['.*/kubernetes/helm/templates/.*%.yaml'] = 'gotmpl',
    ['.*/.zsh/functions/.*'] = 'zsh',
  }
})
