vim.g.colors_name = 'fred-bluloco'
local lush = require 'lush'
package.loaded['lush_theme.bluloco'] = nil
package.loaded['core.colors'] = nil
local theme = require 'core.colors'
lush(theme)
