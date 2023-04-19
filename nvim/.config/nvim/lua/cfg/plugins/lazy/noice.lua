return {
  'folke/noice.nvim',
  enabled = true,
  config = function()
    require('noice').setup {
      messages = {
        enabled = true,
      },
      popupmenu = {
        backend = 'cmp',
      },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = false,
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
          filter = { find = '^Treesitter\n' },
          view = 'popup',
          opts = {
            border = { text = { top = ' :Inspect ' } },
            size = { height = 10 }
          },
        },
        -- Show result of a single highlight command as virtualtext
        {
          filter = {
            event = 'msg_show',
            kind = '',
            find = '^(@?%w-%.?%w*)%s*xxx %w+[^\n]+$',
          },
          view = 'virtualtext',
        },
        -- Show output of multiple highlights in a popup
        {
          filter = {
            event = 'msg_show',
            kind = '',
            find = '^%w-%s*xxx [^\n]+\n',
          },
          view = 'popup',
          opts = {
            border = { text = { top = ' Highlights ' } },
          }
        },
        -- Hide the "E486: Pattern not found" message
        {
          filter = {
            event = 'msg_show',
            kind = 'emsg',
            find = '^E486:',
          },
          opts = { hide = true }
        },
        -- Always route any messages with more than 20 lines to the split view
        {
          filter = { event = 'msg_show', min_height = 20 },
          view = 'split',
        },
        -- Hide all messages with empty kind
        {
          filter = { event = 'msg_show', kind = '' },
          opts = { hide = true }
        },
      }
    }
  end,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  }
}
