return {
  "folke/noice.nvim",
  config = function()
    require("noice").setup {
      messages = {
        enabled = true,
        view = 'mini',
      },
      popupmenu = {
        backend = 'cmp',
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          -- override the lsp markdown formatter with Noice
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- this doesn't work currently
        },
        signature = {
          enabled = true,
        }
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    }
  end,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  }
}
