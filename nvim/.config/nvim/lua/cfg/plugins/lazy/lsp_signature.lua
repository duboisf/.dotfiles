return {
  'ray-x/lsp_signature.nvim',
  enabled = true,
  config = function()
    require('lsp_signature').setup({
      bind = true,
      floating_window = true,
      hint_enable = true,
    })
  end,
}
