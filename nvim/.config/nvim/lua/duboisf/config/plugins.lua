
-- run PackerCompile when we save this file
vim.cmd [[
  augroup duboisf#config#plugins
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]]

vim.g.started_by_firenvim = vim.g.started_by_firenvim or false

return require('packer').startup(function(use)

  use {
    'wbthomason/packer.nvim',
    'justinmk/vim-sneak',
  }

  use {
    'glacambre/firenvim',
    run = function ()
      vim.fn['firenvim#install'](0)
    end
  }

  use {
    'hrsh7th/nvim-compe',
    config = function() require('duboisf.config.plugins.compe') end,
  }

  use {
    'neovim/nvim-lspconfig',
    config = function ()
      require('duboisf.config.plugins.lsp')
    end,
    requires = {'williamboman/nvim-lsp-installer'}
  }
end)
