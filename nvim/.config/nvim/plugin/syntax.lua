local utils = require 'core.utils'

--[[
Avoid uselessly loading vim syntax files for filetypes that have Tree-sitter
parsers. We achieve this by setting 'syntax manual' (in init.vim) instead of
'syntax enable' which stops vim automatically sourcing syntax files when
opening buffers. The drawback is that if there is no Tree-sitter parser for
the current buffer, we need to 'set syntax=ON' to fallback to doing
highlighting the classic, slow way. To avoid having to do this manually, we
create a FileType autocommand to do this for us.
--]]

-- Turn on classic vim syntax highlighting for filetypes that don't have a Tree-sitter parser.
local function missing_treesitter_parser_fallback()
  local ok, parsers = pcall(require, 'nvim-treesitter.parsers')
  if not ok then return end
  local lang = parsers.ft_to_lang(vim.o.filetype)
  if not parsers.has_parser(lang) then
    -- Turn on the classic vim syntax highlighting mechanism
    vim.o.syntax = vim.o.filetype
  end
end

local autocmd = utils.autogroup('user#plugin#syntax', true)

autocmd('FileType', '*', missing_treesitter_parser_fallback,
  "Turn on classic vim highlighting when filetype does't have a treesitter parser")

missing_treesitter_parser_fallback()
