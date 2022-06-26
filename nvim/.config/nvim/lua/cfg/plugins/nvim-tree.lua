require('nvim-tree').setup {
  create_in_closed_folder = true,
  hijack_cursor = true,
  update_focused_file = {
    enable = true,
    update_root = true,
  },
  view = {
    centralize_selection = true,
    mappings = {
      list = {
        { key = 'u', action = 'dir_up' },
      },
    }
  },
}

vim.cmd [[
  nnoremap <leader>v :NvimTreeFindFileToggle<CR>
]]
