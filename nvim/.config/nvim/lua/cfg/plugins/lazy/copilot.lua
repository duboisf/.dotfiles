return {
  "zbirenbaum/copilot.lua",
  cmd = 'Copilot',
  cond = require('core.utils').has_network,
  event = 'InsertEnter',
  opts = {
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
  },
  config = function(_, opts)
    require('copilot').setup(opts)

    vim.keymap.set(
      'n',
      '<leader>ct',
      function()
        require('copilot.suggestion').toggle_auto_trigger()
        if vim.b.copilot_suggestion_auto_trigger then
          print('Copilot auto trigger is enabled')
        else
          print('Copilot auto trigger is disabled')
        end
      end,
      { desc = 'Toggle Copilot LSP' }
    )
  end,
}
