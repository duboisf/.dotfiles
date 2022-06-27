local mode = require('lualine.components.mode')

local function enhanced_mode()
  if active_hydra then
    return string.upper(active_hydra.name)
  end
  return mode()
end

require('lualine').setup {
  options = {
    theme = 'onedark',
    disabled_filetypes = {
      'startify',
    }
  },
  sections = {
    lualine_a = { enhanced_mode },
    lualine_c = {
      {
        'filename',
        path = 1,
      },
    },
    lualine_z = { 'location', '%L' },
  },
  tabline = {
    lualine_b = { 'buffers' },
    lualine_z = { 'tabs' },
  }
}
