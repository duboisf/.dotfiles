return {
  "zbirenbaum/copilot.lua",
  opts = {
    copilot_node_command = "node22x",
    filetypes = {
      gitcommit = true,
      markdown = true,
      yaml = true,
    },
    panel = {
      enabled = true,
      auto_refresh = true,
      keymap = {
        open = false,
      },
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept = "<C-CR>",
        accept_line = "<M-l>",
        accept_word = "<M-j>",
      }
    }
  },
  config = function(_, opts)
    require("copilot").setup(opts)

    local function set(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { desc = desc })
    end

    set(
      'yoc',
      function()
        require("copilot.suggestion").toggle_auto_trigger()
        if vim.b.copilot_suggestion_auto_trigger then
          print("Copilot auto trigger is enabled")
        else
          print("Copilot auto trigger is disabled")
        end
      end,
      "Toggle Copilot suggestions"
    )

    set('[oc', function()
      vim.b.copilot_suggestion_auto_trigger = true
      vim.notify("Copilot suggestions enabled")
    end, "Enable Copilot suggestions")
    set(']oc', function()
      vim.b.copilot_suggestion_auto_trigger = false
      vim.notify("Copilot suggestions disabled")
    end, "Disable Copilot suggestions")
  end,
}
