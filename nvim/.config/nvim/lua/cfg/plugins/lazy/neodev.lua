return {
  'folke/neodev.nvim',
  config = function()
    require('neodev').setup {
      library = {
        enabled = true,
        runtime = true,
        -- Can be a table of plugins to make available as a workspace library.
        -- If true, include all plugins, false means include none.
        plugins = true,
      }
    }
  end,
}
