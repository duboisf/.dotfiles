local function get_statusline_mode()
  local ok, noice = pcall(require, "noice")
  if not ok then
    return
  end
  local ok, theme = pcall(require, "core.colorscheme.theme")
  if not ok then
    return
  end
  return {
    noice.api.statusline.mode.get,
    cond = noice.api.statusline.mode.has,
    color = {
      fg = theme.SpecialKey.fg.hex,
    },
  }
end

local function config()
  local utils = require("core.utils")

  local function get_cwd()
    return " " .. utils.get_short_cwd()
  end

  -- to show current config, use:
  local cfg = {
    options = {
      theme = 'bluloco',
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
      },
      lualine_z = { "location", "%L" },
    },
    tabline = {
      lualine_a = { "buffers" },
      lualine_x = { "tabs" },
      lualine_z = { get_cwd },
    },
  }

  local statusline_mode = get_statusline_mode()
  if statusline_mode ~= nil then
    table.insert(cfg.sections.lualine_x, statusline_mode)
  end

  require("lualine").setup(cfg)
end

return {
  'nvim-lualine/lualine.nvim',
  enabled = require('core.utils').notStartedByFirenvim,
  config = config,
  dependencies = {
    'folke/noice.nvim',
    'kyazdani42/nvim-web-devicons'
  },
}
