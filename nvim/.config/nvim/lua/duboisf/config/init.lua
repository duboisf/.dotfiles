require 'duboisf.config.autopairs'
require 'duboisf.config.gitsigns'
require 'duboisf.config.telescope'
require 'duboisf.config.treesitter'

require'colorizer'.setup()

function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
    return ...
end
