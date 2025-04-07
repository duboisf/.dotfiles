return {
  "folke/which-key.nvim",
  enabled = true,
  opts = {
    preset = "helix",
    sort = { "alphanum", "local", "order", "group", "mod" },
  },
  config = function(_, opts)
    require('which-key').setup(opts)

    -- vim.keymap.set('i', , rhs, opts?)
    -- worakaround for <C-o>, see https://github.com/folke/which-key.nvim/issues/827
    vim.keymap.set("i", "<C-o>", function()
      vim.cmd("startinsert!")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), 'n', false)
    end, { expr = true })
  end
}
