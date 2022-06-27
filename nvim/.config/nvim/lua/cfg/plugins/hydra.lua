local Hydra = require('hydra')

Hydra({
  name = 'Side scroll',
  mode = 'n',
  body = 'z',
  heads = {
    { 'h', '5zh' },
    { 'l', '5zl', { desc = '←/→' } },
    { 'H', 'zH' },
    { 'L', 'zL', { desc = 'half screen ←/→' } },
  },
})

local function incremental_selection()
  return require 'nvim-treesitter.incremental_selection'
end

Hydra({
  name = '🌳 Incremental Selection',
  config = {
    color = 'pink',
    invoke_on_body = true,
    on_enter = function() incremental_selection().init_selection() end,
    on_exit = function() end,
    -- timeout = 1000,
  },
  mode = { 'n', 'x' },
  body = 'gs',
  heads = {
    { 'j', ":lua require'nvim-treesitter.incremental_selection'.node_incremental()<CR>", { desc = 'Node++', silent = true } },
    { 'k', ":lua require'nvim-treesitter.incremental_selection'.node_decremental()<CR>", { desc = 'Node--', silent = true } },
    { 'l', ":lua require'nvim-treesitter.incremental_selection'.scope_incremental()<CR>", { desc = 'Scope++', silent = true } },
    { 'd', 'd', { desc = 'Delete', exit = true } },
    { 'y', 'y', { desc = 'Copy', exit = true } },
    { '<C-c>', '<Esc>', { exit = true } },
    { '<Esc>', '<Esc>', { exit = true } },
  }
})

--Hydra({
--  hint = [[
-- ^^^^^^     Move     ^^^^^^   ^^     Split         ^^^^    Size
-- ^^^^^^--------------^^^^^^   ^^---------------    ^^^^-------------
-- ^ ^ _k_ ^ ^   ^ ^ _K_ ^ ^    _s_: horizont"lly    _+_ _-_: height
-- _h_ ^ ^ _l_   _H_ ^ ^ _L_    _v_: vertically      _>_ _<_: width
-- ^ ^ _j_ ^ ^   ^ ^ _J_ ^ ^    _q_: close           ^ _=_ ^: equalize
-- focus^^^^^^   window^^^^^
-- ^ ^ ^ ^ ^ ^   ^ ^ ^ ^ ^ ^    ^ ^                ^_<Esc>_^: exit
--]] ,
--  config = {
--    timeout = 4000,
--    hint = {
--      border = 'rounded'
--    }
--  },
--  mode = 'n',
--  name = 'Win Management',
--  body = '<C-w>',
--  heads = {
--    -- Move focus
--    { 'h', '<C-w>h' },
--    { 'j', '<C-w>j' },
--    { 'k', '<C-w>k' },
--    { 'l', '<C-w>l' },
--    -- Move window
--    { 'H', '<C-w>H' },
--    { 'J', '<C-w>J' },
--    { 'K', '<C-w>K' },
--    { 'L', '<C-w>L' },
--    -- Split
--    { 's', '<C-w>s' },
--    { 'v', '<C-w>v' },
--    { 'q', '<Cmd>try | close | catch | endtry<CR>', { desc = 'close window' } },
--    -- Size
--    { '+', '<C-w>+' },
--    { '-', '<C-w>-' },
--    { '>', '2<C-w>>', { desc = 'increase width' } },
--    { '<', '2<C-w><', { desc = 'decrease width' } },
--    { '=', '<C-w>=', { desc = 'equalize' } },
--    --
--    { '<Esc>', nil, { exit = true } }
--  }
--})
