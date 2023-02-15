local fn = vim.fn
local utils = require("core.utils")

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false
if fn.empty(fn.glob(install_path)) > 0 then
  vim.notify('packer not installed, cloning...', vim.log.levels.INFO)
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
  vim.cmd 'packadd packer.nvim'
end

local autocmd = utils.autogroup('cfg#packer', true)
autocmd("BufWritePost", "*/cfg/packer.lua",
  "let b:disable_jump_to_last_position = 1 | source <afile> | PackerCompile",
  "Run :PackerCompile when the packer.lua config file gets saved"
)

local packer_config = {
  preview_updates = true,
  profile = { enable = true, threshold = 1 }
}

require('packer').startup({ function(use)
  -- wrapper for use function to require our custom plugin configuration from the lua/cfg/plugins dir
  local function use_with_cfg(opts)
    local full_plugin_name = ''
    if type(opts) == 'string' then
      full_plugin_name = opts
      opts = { full_plugin_name }
    elseif type(opts) == 'table' then
      full_plugin_name = opts[1]
    else
      error('must supply either string or table with first element being the full plugin name')
    end
    local plugin_name = utils.packer.short_plugin_name(full_plugin_name)
    local config_module = 'cfg.plugins.' .. plugin_name
    local config_string = string.format([[
      local ok, maybe_error = pcall(require, '%s')
      if not ok then vim.notify('cfg/packer.lua: problem with module "%s":\n' .. maybe_error) end
    ]], config_module, config_module)
    opts.config = config_string
    use(opts)
  end

  local function notStartedByFirenvim()
    return vim.g.started_by_firenvim == nil
  end

  use {
    -- need to load this first to reap the benefits of the speedup provided by impatient.nvim
    -- we need to do require('impatient') as early as possible, like the top of init.vim
    'lewis6991/impatient.nvim',
    'michaeljsmith/vim-indent-object',
    'tpope/vim-commentary',
    'tpope/vim-eunuch',
    'tpope/vim-repeat',
    'tpope/vim-unimpaired',
    'wbthomason/packer.nvim',
  }

  -- show indentation guides
  use_with_cfg {
    'lukas-reineke/indent-blankline.nvim',
  }

  use {
    'kylechui/nvim-surround',
    config = function() require('nvim-surround').setup {} end
  }

  use {
    'ggandor/leap.nvim',
    config = function() require('leap').set_default_keymaps() end,
  }

  use {
    'windwp/nvim-autopairs',
    config = function() require 'cfg.plugins.autopairs' end,
  }

  use {
    'gpanders/editorconfig.nvim',
    cond = notStartedByFirenvim,
  }

  use {
    'mhinz/vim-startify',
    cond = notStartedByFirenvim,
  }

  use {
    "folke/twilight.nvim",
    config = function() require("twilight").setup {} end
  }

  -- vim-sensible sets things like ruler and laststatus which we don't want when we are using firenvim
  -- use {
  --   'tpope/vim-sensible',
  --   cond = notStartedByFirenvim,
  -- }

  use {
    'tsandall/vim-rego',
    ft = { 'rego' },
    config = function()
      vim.cmd [[
        " vim-rego configuration
        let g:formatdef_rego = '"opa fmt"'
        let g:formatters_rego = ['rego']
        let g:autoformat_autoindent = 0
        let g:autoformat_retab = 0
      ]]
    end
  }

  use {
    'tpope/vim-fugitive',
    config = function()
      -- open :G in a maximized window
      vim.cmd 'nnoremap ,g :G<CR>'
    end,
  }

  use { 'tpope/vim-rhubarb', after = 'vim-fugitive' }

  use {
    'rafcamlet/nvim-luapad',
    cmd = { 'Luapad' },
  }


  use_with_cfg {
    'anuvyklack/hydra.nvim',
    after = { 'keymap-layer.nvim' },
    requires = { 'anuvyklack/keymap-layer.nvim' },
  }

  -- show diff signs in the gutter
  use_with_cfg 'lewis6991/gitsigns.nvim'

  --[[

    dear
    sweet
    telescope

  --]]
  local function use_telescope()
    use_with_cfg {
      -- requires git, fd, ripgrep
      'nvim-telescope/telescope.nvim',
      cond = notStartedByFirenvim,
      after = {
        'hydra.nvim',
        'which-key.nvim'
      },
      requires = {
        'kyazdani42/nvim-web-devicons',
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
      },
    }

    -- support fzf syntax in the telescope prompt
    use {
      'nvim-telescope/telescope-fzf-native.nvim',
      after = 'telescope.nvim',
      run = 'make',
      config = function() require('telescope').load_extension 'fzf' end
    }

    -- search for github resources using telescope
    use {
      'nvim-telescope/telescope-github.nvim',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension 'gh' end
    }

    -- set vim.ui.select to telescope for a better picking experience for things
    -- like lsp code actions
    use {
      'nvim-telescope/telescope-ui-select.nvim',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension 'ui-select' end
    }
  end

  -- various commands to work with golang
  use_with_cfg {
    'fatih/vim-go',
    ft = { 'go', 'gomod' },
  }

  use {
    'NvChad/nvim-colorizer.lua',
    config = function() require('colorizer').setup {} end
  }

  -- preview markdown in browser with live position synchronization
  use {
    'iamcco/markdown-preview.nvim',
    run = ':call mkdp#util#install()',
    ft = { 'markdown' },
    setup = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_browserfunc = 'EchoMarkdownPreviewUrl'
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  }

  -- use neovim in any text input in the browser 🤯
  use_with_cfg {
    'glacambre/firenvim',
    run = function() vim.fn['firenvim#install'](0) end,
  }

  -- use popup window when using the vim.notify api
  use_with_cfg {
    'rcarriga/nvim-notify',
    after = 'telescope.nvim',
  }

  -- fast and easily configurable status line written in lua 🌕
  use_with_cfg {
    'nvim-lualine/lualine.nvim',
    cond = notStartedByFirenvim,
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  -- file browser
  use_with_cfg {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
  }

  -- show fancy cursor line movement
  use_with_cfg 'gen740/SmoothCursor.nvim'

  --[[

    dear
    sweet
    LSP

  --]]
  local function use_lsp()
    -- don't hunt around the web to install language servers
    use {
      'williamboman/mason.nvim',
      config = function() require('mason').setup() end,
    }

    -- simplify language server configuration
    use_with_cfg {
      'neovim/nvim-lspconfig',
      after = {
        'aerial.nvim',
        'mason.nvim',
        'nvim-cmp',
      }
    }

    use_with_cfg {
      'jose-elias-alvarez/null-ls.nvim',
      after = 'nvim-lspconfig',
      requires = {
        'nvim-lua/plenary.nvim',
      }
    }

    use {
      'MunifTanjim/prettier.nvim',
      after = { 'null-ls.nvim' },
      config = function()
        local prettier = require 'prettier'
        prettier.setup({
          bin = 'prettier', -- or `'prettierd'` (v0.22+)
          filetypes = {
            "css",
            "graphql",
            "html",
            "javascript",
            "javascriptreact",
            "json",
            "less",
            "markdown",
            "scss",
            "typescript",
            "typescriptreact",
            "yaml",
          },
        })
      end
    }

    -- Don't use this yet, has potential but still buggy
    use({
      "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
      cond = false,
      config = function()
        require('lsp_lines').setup()
      end,
      after = { 'nvim-lspconfig' }
    })
  end

  --[[

    dear
    sweet
    completion

  --]]
  local function use_completion()
    -- snippets engine written in lua
    use {
      'L3MON4D3/LuaSnip',
      after = { 'nvim-cmp' },
      config = function() require 'cfg.plugins.luasnip' end,
    }
    for _, source in ipairs({
      -- complete words from other buffers
      'hrsh7th/cmp-buffer',
      -- completion when in nvim commandline
      'hrsh7th/cmp-cmdline',
      -- complete words from the dictionary
      'uga-rosa/cmp-dictionary',
      -- complete emojis like :tada:
      'hrsh7th/cmp-emoji',
      -- completion for filesystem paths
      'hrsh7th/cmp-path',
      -- completion for luasnip snippets
      'saadparwaiz1/cmp_luasnip',
    }) do
      use { source, after = 'nvim-cmp' }
    end

    -- fancy completion
    use_with_cfg {
      'hrsh7th/nvim-cmp',
      requires = {
        -- add vscode-line pictograms in completion popup
        'onsails/lspkind.nvim',
        -- completion suggestions from language server
        'hrsh7th/cmp-nvim-lsp',
        'nvim-lua/plenary.nvim',
      },
      after = { 'nvim-autopairs' }
    }

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

  --[[

    dear
    sweet
    treesitter

  --]]
  local function use_treesitter()

    use_with_cfg {
      'nvim-treesitter/nvim-treesitter',
      run = function()
        require('nvim-treesitter.install').update()
      end
    }

    use {
      'nvim-treesitter/playground',
      after = 'nvim-treesitter',
    }

    use {
      'nvim-treesitter/nvim-treesitter-context',
      config = function() require('treesitter-context').setup {} end,
      after = 'nvim-treesitter',
    }

    use {
      'nvim-treesitter/nvim-treesitter-textobjects',
      after = 'nvim-treesitter',
    }

    use {
      'p00f/nvim-ts-rainbow',
      after = 'nvim-treesitter',
    }
  end

  local function use_colorscheme()
    -- colorscheme
    use_with_cfg 'navarasu/onedark.nvim'
  end

  -- show the available mappings when pressing part of a multi-key mapping
  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  -- color picker, use the PickColor command
  use {
    'ziontee113/color-picker.nvim',
    config = function() require 'color-picker' end,
  }

  -- code outline
  use {
    'stevearc/aerial.nvim',
    config = function() require('aerial').setup() end
  }

  -- take notes zettelkasten-style
  use {
    'mickael-menu/zk-nvim',
    config = function() require 'cfg.plugins.zk' end
  }

  use {
    "folke/noice.nvim",
    config = function()
      require("noice").setup {
        popupmenu = {
          backend = 'cmp',
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            -- override the lsp markdown formatter with Noice
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = false, -- this doesn't work currently
          },
          signature = {
            enabled = false,
          }
        },
        presets = {
          lsp_doc_border = true,
        }
      }
    end,
    after = {
      'nvim-notify',
      'nvim-treesitter',
      'nvim-cmp',
    },
    requires = { 'MunifTanjim/nui.nvim' }
  }

  use_colorscheme()
  use_completion()
  use_lsp()
  use_telescope()
  use_treesitter()

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end, config = packer_config })
