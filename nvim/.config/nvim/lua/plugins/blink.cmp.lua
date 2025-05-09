---@module 'blink.cmp.config'

vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpMenuOpen',
  callback = function()
    local ok, suggestion = pcall(require, "copilot.suggestion")
    if not ok then
      return
    end
    if suggestion.is_visible() then
      suggestion.dismiss()
    end
    vim.b.copilot_suggestion_hidden = true
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpMenuClose',
  callback = function()
    vim.b.copilot_suggestion_hidden = false
  end,
})

return {
  'saghen/blink.cmp',

  -- optional: provides snippets for the snippet source
  dependencies = {
    'rafamadriz/friendly-snippets',
  },

  -- use a release tag to download pre-built binaries
  version = '1.*',

  ---@type blink.cmp.Config
  opts = {
    snippets = {
      expand = function(snippet)
        if string.find(snippet, "$CLIPBOARD") then
          local clipboard = vim.fn.getreg('+')
          snippet = string.gsub(snippet, "$CLIPBOARD", clipboard)
        end
        vim.snippet.expand(snippet)
      end
    },
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = 'enter',
      ['<Tab>'] = {
        function(cmp)
          if not cmp.snippet_active() then
            return cmp.select_next()
          end
        end,
        'snippet_forward',
        'fallback',
      },
    },
    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = {
      accept = {
        auto_brackets = {
          semantic_token_resolution = {
            blocked_filetypes = { 'java', 'go' },
          },
          enabled = true,
        },
      },
      documentation = {
        auto_show = false,
      },
      ghost_text = {
        enabled = false,
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },
    },

    signature = {
      enabled = true,
    },

    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
}
