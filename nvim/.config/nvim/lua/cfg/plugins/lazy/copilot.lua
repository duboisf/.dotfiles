return {
  "zbirenbaum/copilot.lua",
  cmd = 'Copilot',
  enabled = true,
  event = 'InsertEnter',
  config = function()
    local copilot = require 'copilot'
    copilot.setup {
      filetypes = {
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

    local suggestion = require 'copilot.suggestion'
    vim.keymap.set('i', '<C-CR>', suggestion.accept, { noremap = true, silent = true })
  end,
}
