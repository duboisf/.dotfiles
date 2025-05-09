return {
  'stevearc/conform.nvim',
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
    },
    format_on_save = {
      async = false,
      lsp_format = "fallback",
      timeout_ms = 500,
    },
  },
}
