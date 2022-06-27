require('nvim-tree').setup {
  create_in_closed_folder = true,
  hijack_cursor = true,
  update_focused_file = {
    enable = false,
    update_root = true,
  },
  view = {
    centralize_selection = true,
    mappings = {
      list = {
        { key = 'u', action = 'dir_up' },
        { key = 'h', action = 'toggle_dotfiles' },
        { key = 'H', action = '' },
      },
    }
  },
}

vim.cmd [[
  nnoremap <leader>v :NvimTreeFindFileToggle<CR>
]]
