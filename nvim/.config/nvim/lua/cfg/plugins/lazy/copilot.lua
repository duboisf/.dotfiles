return {
  "zbirenbaum/copilot.lua",
  cmd = 'Copilot',
  enabled = true,
  event = 'InsertEnter',
  config = true,
  opts = {
    panel = {
      enabled = true,
      auto_refresh = true,
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
    }
  }
}
