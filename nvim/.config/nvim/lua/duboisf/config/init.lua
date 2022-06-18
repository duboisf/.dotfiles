-- Load packer
require 'duboisf.config.plugins'

local cmd = vim.cmd
local fn = vim.fn

-- define a bunch of autocommands to help with lazy loading
local group = vim.api.nvim_create_augroup('duboisf#config#plugins', { clear = true })

local autocmd = function(events, callback)
  if type(events) == 'string' then
    events = { events }
  end
  vim.api.nvim_create_autocmd(events, {
    group = group,
    pattern = "*",
    callback = callback
  })
end
