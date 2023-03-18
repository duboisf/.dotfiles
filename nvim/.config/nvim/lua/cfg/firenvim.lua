local M = {}

-- Try to make nvim optimal when we only have an nvim window that's just 2-3 lines high
function M.on_ui_enter(event)
  if type(event.chan) == "number" then
    local info = vim.api.nvim_get_chan_info(event.chan)
    if info and info.client and info.client.name == 'Firenvim' then
      local o = vim.o
      -- Never show the status line
      o.laststatus = 0
      -- Don't show the line and column of the cursor position
      o.ruler = false
      -- Don't show open tabs and buffers on the first line
      o.showtabline = 0
      -- Reduce cmd lines to minimum. For now the min is 1.
      -- TODO after https://github.com/neovim/neovim/pull/16251 gets released the
      -- min is going to be 0
      o.cmdheight = 1
      -- set min lines to 30, nvim-cmp isn't happy when there aren't
      -- enough lines in the screen
      if vim.o.lines < 30 then
        vim.o.lines = 30
      end
    end
  end
end

return M
