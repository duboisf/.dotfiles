
require('packer').startup({ function(use)
  use {
    'kylechui/nvim-surround',
    config = function() require('nvim-surround').setup {} end
  }

  use {
    'windwp/nvim-autopairs',
    config = function() require 'cfg.plugins.packer.autopairs' end,
  }
  -- show fancy cursor line movement
  use_with_cfg 'gen740/SmoothCursor.nvim'

  --[[

    dear
    sweet
    completion

  --]]
  local function use_completion()
    use {
      'ray-x/lsp_signature.nvim',
      config = function()
        require("lsp_signature").setup {
          bind = true, -- This is mandatory, otherwise border config won't get registered.
          cursorhold_update = false,
          handler_opts = {
            border = "rounded"
          },
          hint_enable = false, -- no virtual text with a panda
          noice = false,
        }
      end
    }

  end

  -- use {
  --   "folke/noice.nvim",
  --   cond = true,
  --   config = function()
  --     require("noice").setup {
  --       messages = {
  --         enabled = false,
  --         view = 'mini',
  --       },
  --       popupmenu = {
  --         backend = 'cmp',
  --       },
  --       lsp = {
  --         override = {
  --           ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
  --           -- override the lsp markdown formatter with Noice
  --           ["vim.lsp.util.stylize_markdown"] = true,
  --           ["cmp.entry.get_documentation"] = false, -- this doesn't work currently
  --         },
  --         signature = {
  --           enabled = false,
  --         }
  --       },
  --       presets = {
  --         lsp_doc_border = true,
  --       },
  --       routes = {
  --         -- avoid search messages since we use virtual text for this purpose
  --         {
  --           filter = {
  --             event = "msg_show",
  --             kind = "search_count",
  --           },
  --           opts = { skip = true },
  --         }
  --       },
  --     }
  --   end,
  --   after = {
  --     'nvim-treesitter',
  --     'nvim-cmp',
  --   },
  --   requires = { 'MunifTanjim/nui.nvim' }
  -- }

  -- Automatically set up your configuration after cloning packer.nvim
end, config = packer_config })
