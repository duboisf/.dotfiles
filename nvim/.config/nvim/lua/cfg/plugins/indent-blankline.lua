require('indent_blankline').setup {
  filetype_exclude = {
    -- defaults
    "checkhealth",
    "help",
    "lspinfo",
    "man",
    "packer",
    "",
    -- I added these
    "TelescopePrompt",
    "startify",
  },
  show_current_context = true,
  -- performance hog
  show_current_context_start = false,
  use_treesitter = true,
  -- disabled as often picks a larger context than desired, like function context
  use_treesitter_scope = false,
}
