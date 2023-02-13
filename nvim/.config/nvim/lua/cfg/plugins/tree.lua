require('nvim-tree').setup {
  auto_reload_on_write = true,
  hijack_netrw = true,
  create_in_closed_folder = false,
  filters = {
    dotfiles = false,
  },
  diagnostics = {
    enable = true,
    show_on_dirs = false,
    debounce_delay = 50,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  hijack_cursor = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    adaptive_size = false,
    centralize_selection = true,
    mappings = {
      list = {
        { key = 'u', action = 'dir_up' },
        { key = 'h', action = 'toggle_dotfiles' },
        { key = 'H', action = '' },
      },
    },
  },
  renderer = {
    icons = {
      glyphs = {
        git = {
          staged = "",
          unstaged = "",
          untracked = "",
        }
      },
      show = {
        file = true,
        folder = true,
        folder_arrow = false,
        git = true,
      },
    },
    indent_markers = {
      enable = true
    },
  }
}

vim.cmd [[
  nnoremap <leader>v :NvimTreeFindFileToggle<CR>
]]
