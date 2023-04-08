local function config()
  local utils = require("core.utils")

  local function get_cwd()
    return " " .. utils.get_short_cwd()
  end

  -- to show current config, use:
  require("lualine").setup {
    options = {
      theme = "onedark",
      disabled_filetypes = {
        "startify",
        "TelescopePrompt",
      },
      globalstatus = true,
    },
    sections = {
      lualine_b = { { "branch", icon = "" }, "diagnostics" },
      lualine_c = { { "filename", path = 1 }, },
      lualine_x = {
        "filetype",
        -- {
        --   require("noice").api.statusline.mode.get,
        --   cond = require("noice").api.statusline.mode.has,
        --   color = { fg = "#ff9e64" },
        -- }
      },
      lualine_z = { "location", "%L" },
    },
    tabline = {
      lualine_a = { "buffers" },
      lualine_x = { "tabs" },
      lualine_z = { get_cwd },
    },
  }
end

return {
  'nvim-lualine/lualine.nvim',
  enabled = require('core.utils').notStartedByFirenvim,
  config = config,
  dependencies = {
    'kyazdani42/nvim-web-devicons'
  },
}
