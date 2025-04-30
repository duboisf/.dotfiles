local utils = require('core.utils')
local go = require('core.go')

local function reload_module(opts)
  local module = opts.args ~= '' and opts.args or vim.fn.expand('%')
  utils.reload_module(module)
end

vim.api.nvim_create_user_command('ReloadModule', reload_module, { nargs = '?' })

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*/pkg/mod/*/*.go',
  callback = function(args)
    if vim.b.go_open_github_package then
      return
    end
    print('GoOpenGithubPackage')
    vim.api.nvim_buf_create_user_command(args.buf, 'GoOpenGithubPackage', function()
      local pkg_path = vim.fn.expand('%:p')
      go.open_github_repo_url(pkg_path)
    end, { nargs = 0 })
    vim.b.go_open_github_package = true
  end,
})

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
