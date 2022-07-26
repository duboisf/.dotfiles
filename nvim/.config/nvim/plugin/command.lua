local utils = require 'core.utils'

local function reload_module(opts)
  local module = opts.args ~= '' and opts.args or vim.fn.expand('%')
  utils.reload_module(module)
end

vim.api.nvim_create_user_command('ReloadModule', reload_module, { nargs = '?' })

local function telescope_find_config()
  require('telescope.builtin').find_files {
    cwd = vim.fn.stdpath('config'),
    prompt_title = 'nvim config files',
  }
end

vim.api.nvim_create_user_command('Config', telescope_find_config, {})

local function telescope_find_data()
  require('telescope.builtin').find_files {
    cwd = vim.fn.stdpath('data'),
    prompt_title = 'nvim plugins',
  }
end

vim.api.nvim_create_user_command('Plugins', telescope_find_data, {})
