return {
  'tpope/vim-eunuch',
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', ',g', ':Git<CR>', { noremap = true, silent = true })
    end
  },
  'tpope/vim-rhubarb',
  'tpope/vim-repeat',
  'tpope/vim-unimpaired',
}
