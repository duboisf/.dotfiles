local utils = require("core.utils")

local function get_cwd()
  return " " .. utils.get_short_cwd()
end

-- to show current config, use:
-- dump(require("lualine").get_config())
require("lualine").setup {
  options = {
    theme = "onedark",
    disabled_filetypes = {
      "startify",
      "TelescopePrompt",
    }
  },
  sections = {
    lualine_b = { {"branch", icon = "" }, "diff", "diagnostics" },
    lualine_c = { { "filename", path = 1 }, },
    lualine_x = { "filetype" },
    lualine_z = { "location", "%L" },
  },
  tabline = {
    lualine_a = { "buffers" },
    lualine_x = { "tabs" },
    lualine_z = { get_cwd },
  }
}
