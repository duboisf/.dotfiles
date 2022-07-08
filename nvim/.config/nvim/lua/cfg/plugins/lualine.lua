local utils = require('core.utils')

local function get_cwd()
  return ' ' .. utils.get_short_cwd()
end

-- to show current config, use:
-- dump(require('lualine').get_config())
require('lualine').setup {
  options = {
    theme = 'onedark',
    disabled_filetypes = {
      'startify',
    }
  },
  sections = {
    lualine_c = { { 'filename', path = 1 }, },
    lualine_x = { get_cwd, "encoding", "fileformat", "filetype" },
    lualine_z = { 'location', '%L' },
  },
  tabline = {
    lualine_b = { 'buffers' },
    lualine_z = { 'tabs' },
  }
}
