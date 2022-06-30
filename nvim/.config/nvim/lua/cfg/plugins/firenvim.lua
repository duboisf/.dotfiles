-- when you edit some rich textareas, it inserts a bunch of paragraphs (<p>)
-- and <br> which translates into 4 blank line in nvim for every blank line in
-- the textarea
local function remove_duplicates_lines(event)
  local filtered_lines = {}
  local consecutive_blank_lines = 0
  local lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)
  for _, line in ipairs(lines) do
    if line == '' then
      consecutive_blank_lines = consecutive_blank_lines + 1
      if consecutive_blank_lines >= 4 then
        consecutive_blank_lines = 0
        table.insert(filtered_lines, line)
      end
    else
      table.insert(filtered_lines, line)
    end
  end
  vim.api.nvim_buf_set_lines(event.buf, 0, -1, false, filtered_lines)
end

local group = vim.api.nvim_create_augroup("cfg#firenvim", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  pattern = "github.com_*.txt",
  desc = "Set filetype to markdown when using firenvim on github",
  command = "set filetype=markdown",
})

vim.api.nvim_create_autocmd("BufRead", {
  group = group,
  pattern = "app.asana.com_*.txt",
  desc = "Remove duplicate lines",
  callback = remove_duplicates_lines,
})

vim.g.firenvim_config = {
  globalSettings = {
    alt = 'all',
  },
  localSettings = {
    ['.*'] = {
      cmdline = 'neovim',
      priority = 0,
      selector = 'textarea',
      takeover = 'never',
    },
    ['https://app.asana.com/.*'] = {
      cmdline = 'neovim',
      content = 'text'
    }
  }
}
