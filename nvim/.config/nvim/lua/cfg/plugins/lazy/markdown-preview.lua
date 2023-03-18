return {
  'iamcco/markdown-preview.nvim',
  build = ':call mkdp#util#install()',
  ft = { 'markdown' },
  config = function()
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_browserfunc = 'EchoMarkdownPreviewUrl'
    vim.g.mkdp_echo_preview_url = 1
    vim.g.mkdp_filetypes = { "markdown" }
  end,
}
