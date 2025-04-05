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

vim.api.nvim_create_user_command('EditTheme', function()
  local paths = vim.api.nvim_get_runtime_file('lua/core/colors.lua', false)
  if #paths ~= 1 then
    vim.notify('Could not find location of the theme file', vim.log.levels.ERROR, {
      timeout = 500,
      title = 'EditTheme',
    })
    return
  end
  local theme_path = paths[1]
  vim.cmd.vsplit(theme_path)
  vim.cmd.Lushify()
end, {})

vim.api.nvim_create_user_command("WTF", function(args)
  require("duboisf.wtf")(args.fargs[1])
end, { nargs = 1 })
