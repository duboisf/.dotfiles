local g = vim.g

g['airline#extensions#tabline#enabled'] = 1
g['airline#extensions#tabline#buffer_nr_show'] = 1
g['airline_powerline_fonts'] = 1
g['airline#extensions#tabline#formatter'] = 'unique_tail_improved'

  -- fu FredTreesitterStatus()
  --   let l:status = nvim_treesitter#statusline(100)
  --   if l:status ==# "null"
  --     return ""
  --   else
  --     return "🌳 " . l:status
  --   endif
  -- endfu

  -- fu s:airline_treesitter_init()
  --   if exists("*airline#parts#define_function")
  --     call airline#parts#define_function('treesitter-status', 'FredTreesitterStatus')
  --     let g:airline_section_x = airline#section#create_right(['bookmark', 'tagbar', 'vista', 'gutentags', 'grepper', 'treesitter-status', 'filetype'])
  --   endif
  -- endfu

  -- aug fred#airline
  --   au!
  --   " au User AirlineAfterInit call s:airline_treesitter_init()
  -- aug end
-- ]]
