return {
  "folke/noice.nvim",
  enabled = true,
  config = function()
    require("noice").setup {
      messages = {
        enabled = true,
      },
      popupmenu = {
        backend = 'cmp',
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = false,
        },
        signature = {
          enabled = true,
        },
        progress = {
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
      routes = {
        -- Show :Inspect result in a popup
        {
          filter = {
            find = "Treesitter",
          },
          view = "popup",
          opts = {
            size = {
              height = "20%",
            }
          }
        },
        -- Show highlight as virtualtext
        {
          filter = {
            find = " xxx ",
          },
          view = "virtualtext",
        },
        -- Hide the "written" message when saving a file
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { hide = true },
        }
      }
    }
  end,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  }
}
