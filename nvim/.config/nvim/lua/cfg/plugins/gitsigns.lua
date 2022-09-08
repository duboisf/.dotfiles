local utils = require 'core.utils'

local gitsigns = require('gitsigns')

gitsigns.setup {
  debug_mode = false,
  -- current_line_blame = true,
  -- current_line_blame_opts = {
  --   delay = 3000,
  -- },
  preview_config = {
    border = 'rounded',
  },
  -- word_diff = true,
  on_attach = function(bufnr)
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    local function nmap(l, r, opts) map('n', l, r, opts) end

    -- Navigation
    nmap(']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
    nmap('[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

    local gs = gitsigns

    -- Actions
    map({ 'n', 'v' }, '<leader>hs', gs.stage_hunk)
    map({ 'n', 'v' }, '<leader>hr', gs.reset_hunk)
    nmap('<leader>hS', gs.stage_buffer)
    nmap('<leader>hu', gs.undo_stage_hunk)
    nmap('<leader>hR', gs.reset_buffer)
    nmap('<leader>hp', gs.preview_hunk)
    nmap('<leader>hb', function() gs.blame_line { full = true } end)
    nmap('<leader>htb', gs.toggle_current_line_blame)
    nmap('<leader>hd', gs.diffthis)
    nmap('<leader>hD', function() gs.diffthis('~') end)
    nmap('<leader>htd', gs.toggle_deleted)

    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}
