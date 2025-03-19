return {
  'folke/noice.nvim',
  enabled = false,
  config = function()
    require("noice").setup({
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false,       -- add a border to hover docs and signature help
      },
    })
    -- require('noice').setup {
    --   messages = {
    --     enabled = true,
    --   },
    --   popupmenu = {
    --     backend = 'cmp',
    --   },
    --   lsp = {
    --     override = {
    --       ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
    --       ['vim.lsp.util.stylize_markdown'] = true,
    --       ['cmp.entry.get_documentation'] = false,
    --     },
    --     signature = {
    --       enabled = true,
    --     },
    --     progress = {
    --       enabled = true,
    --     }
    --   },
    --   presets = {
    --     bottom_search = false,
    --     command_palette = true,
    --     long_message_to_split = true,
    --     inc_rename = false,
    --     lsp_doc_border = true,
    --   },
    --   routes = {
    --     -- Show :Inspect result in a popup
    --     {
    --       filter = { find = '^Treesitter\n' },
    --       view = 'popup',
    --       opts = {
    --         border = { text = { top = ' :Inspect ' } },
    --         size = { height = 10 }
    --       },
    --     },
    --     -- Hide the "E486: Pattern not found" message
    --     {
    --       filter = {
    --         event = 'msg_show',
    --         kind = 'emsg',
    --         find = '^E486:',
    --       },
    --       opts = { hide = true }
    --     },
    --     -- Always route any messages with more than 20 lines to the split view
    --     {
    --       filter = { event = 'msg_show', min_height = 20 },
    --       view = 'split',
    --     },
    --     -- Use mini view for all messages with empty kind
    --     {
    --       filter = { event = 'msg_show', kind = '' },
    --       view = 'mini',
    --     },
    --   }
    -- }
  end,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  }
}
