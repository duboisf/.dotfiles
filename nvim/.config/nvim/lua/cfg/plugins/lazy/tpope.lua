return {
  -- 'tpope/vim-commentary',
  'tpope/vim-eunuch',
  {
    'tpope/vim-fugitive',
    cmd = 'G',
    keys = {
      { ',g', ':G<CR>', 'Open fugitive' }
    },
  },
  {
    'tpope/vim-rhubarb',
    dependencies = {
      'tpope/vim-fugitive',
    },
  },
  'tpope/vim-repeat',
  'tpope/vim-unimpaired',
}
