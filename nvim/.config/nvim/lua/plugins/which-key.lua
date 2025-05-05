return {
  "folke/which-key.nvim",
  enabled = false,
  opts = {
    preset = "helix",
    sort = { "alphanum", "local", "order", "group", "mod" },
    show_help = false,
  },
  -- config = function(_, opts)
  --   require('which-key').setup(opts)
  --
  --   -- worakaround for <C-o>, see https://github.com/folke/which-key.nvim/issues/827
  --   vim.keymap.set("i", "<C-o>", function()
  --     vim.cmd("startinsert!")
  --     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), 'n', false)
  --   end, { expr = true })
  -- end
}
