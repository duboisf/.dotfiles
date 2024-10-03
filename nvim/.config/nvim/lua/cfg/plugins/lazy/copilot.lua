return {
  "zbirenbaum/copilot.lua",
  cmd = 'Copilot',
  cond = require('core.utils').has_network,
  event = 'InsertEnter',
  config = function()
    local copilot = require 'copilot'
    copilot.setup {
      copilot_node_command = 'node20x',
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
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'Force Copilot to attach to NeogitCommitMessage buffers',
      pattern = 'NeogitCommitMessage',
      callback = function()
        require('copilot.client').buf_attach(true)
      end
    }
    )
  end,
}
