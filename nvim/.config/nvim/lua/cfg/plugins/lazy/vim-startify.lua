return {
  'mhinz/vim-startify',
  enable = require('core.utils').notStartedByFirenvim,
  config = function()
    -- don't change cwd when jumping to a file
    vim.g.startify_change_to_dir = 0

    vim.g.startify_lists = {
      { type = 'dir', header = {'   MRU ' .. vim.fn.getcwd()} },
      { type = 'files', header= {'   MRU'}, },
      { type = 'sessions', header= {'   Sessions'} },
      { type = 'bookmarks', header= {'   Bookmarks'} },
      { type = 'commands',  header= {'   Commands'} },
    }
  end,
}
