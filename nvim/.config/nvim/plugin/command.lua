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

--- Delete Go struct members from spew output
---@param pattern string
local function delete_go_struct_members(pattern)
  if not pattern or pattern == '' then
    print("No pattern provided")
    return
  end
  pattern = string.format("^\\s*%s: (", pattern)
  if vim.fn.search(pattern, 'nw') > 0 then
    -- Delete members that are contained on 1 line
    vim.cmd(string.format('normal! g/%s.*),$/d', pattern))
  end
  local batch_size = 10
  local count = 0
  -- Delete members that are on multiple lines
  while vim.fn.search(pattern, 'nw') > 0 do
    vim.cmd(string.format('silent! normal! /%s\r$V%%d0', pattern))
    count = count + 1
    if count % batch_size == 0 then
      -- Force redraw to show progress
      vim.cmd('redraw')

      -- Show progress message
      print(string.format("Processing... %d matches deleted", count))

      -- Allow Neovim to process other events
      vim.cmd('sleep 1m') -- 1 millisecond pause

      -- Check for user interrupt (Ctrl-C)
      if vim.fn.getchar(0) == 3 then -- Ctrl-C
        print(string.format("Interrupted by ctrl-c after %d deletions", count))
        return
      end
    end
    -- Safety break to prevent infinite loops
    if count > 1000 then
      print("Stopped after 1000 iterations (safety limit)")
      break
    end
  end
  if count > 0 then
    print(string.format("Processed %d compiler: matches", count))
  else
    print("No compiler: patterns found")
  end
end

vim.api.nvim_create_user_command('DeleteGoStructMembers', function(opts)
  delete_go_struct_members(opts.args)
end, {
  nargs = 1,
  desc = "Delete a Go struct member from spew output"
})
