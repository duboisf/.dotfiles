return {
  "zbirenbaum/copilot.lua",
  cmd = 'Copilot',
  dependencies = { 'folke/which-key.nvim' },
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
        auto_trigger = false,
        keymap = {
          accept = false,
          accept_word = '<M-l>',
        }
      }
    }

    local function toggle_auto_trigger()
      require('copilot.suggestion').toggle_auto_trigger()
    end

    -- add keymap to toggle auto trigger <leader>cc (code complete)
    require('which-key').add({
      {
        '<leader>cc',
        function()
          require('copilot.suggestion').toggle_auto_trigger()
          if vim.b.copilot_suggestion_auto_trigger then
            print('AI code suggestion auto trigger is enabled')
          else
            print('AI code suggestion auto trigger is disabled')
          end
        end,
        desc = 'Toggle AI suggestion auto trigger',
      },
    })
  end,
}
