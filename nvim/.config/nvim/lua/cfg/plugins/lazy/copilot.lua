return {
  "zbirenbaum/copilot.lua",
  cmd = 'Copilot',
  cond = require('core.utils').has_network,
  event = 'InsertEnter',
  config = function()
    local copilot = require 'copilot'
    copilot.setup {
      filetypes = {
        gitcommit = true,
        markdown = true,
        yaml = true,
      },
      panel = {
        enabled = true,
        auto_refresh = true,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = false,
          accept_word = '<M-l>',
        }
      }
    }
  end,
}
