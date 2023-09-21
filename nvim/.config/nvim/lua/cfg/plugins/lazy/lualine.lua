local utils = require("core.utils")

local function get_statusline_mode()
  local ok, noice = pcall(require, "noice")
  if not ok then
    return
  end
  local theme
  ok, theme = pcall(require, "core.colors")
  if not ok then
    return
  end
  return {
    noice.api.status.mode.get,
    cond = noice.api.status.mode.has,
    color = {
      fg = theme.SpecialKey.fg.hex,
    },
  }
end

local function config()
  local function get_cwd()
    return " " .. utils.get_short_cwd()
  end

  local theme = require 'core.colors'
  local lualine_bluloco = require 'lualine.themes.bluloco'
  lualine_bluloco.insert.a.bg = theme.Attribute.fg.hex
  lualine_bluloco.insert.b.fg = lualine_bluloco.insert.a.bg
  lualine_bluloco.normal.b.fg = lualine_bluloco.normal.a.bg

  local cfg = {
    options = {
      theme = lualine_bluloco,
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

  local lualine = require 'lualine'

  lualine.setup(cfg)
end

local autocmd = utils.autogroup('core.colors', false)
autocmd('ColorScheme', '*', function()
  package.loaded['lualine.themes.bluloco'] = nil
  config()
end, 'Reload lualine on colorscheme change')

return {
  'nvim-lualine/lualine.nvim',
  config = config,
  dependencies = {
    'kyazdani42/nvim-web-devicons'
  },
}
