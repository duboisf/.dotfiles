require 'lualine'.setup {
  options = {
    theme = 'onedark',
    disabled_filetypes = {
      'startify',
    }
  },
  sections = {
    lualine_c = {
      {
        'filename',
        path = 1,
      },
    }
  },
  tabline = {
    lualine_b = { 'buffers' },
    lualine_z = { 'tabs' },
  }
}
