local function config()
  local action_set = require 'telescope.actions.set'
  local action_state = require 'telescope.actions.state'
  local actions = require 'telescope.actions'
  local builtin = require 'telescope.builtin'
  local putils = require 'telescope.previewers.utils'
  local themes = require 'telescope.themes'
  local tutils = require 'telescope.utils'
  local utils = require 'core.utils'
  local which_key = require 'which-key'

  local function nmap(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, {
      desc = 'Telescope: ' .. desc,
      silent = true,
      noremap = true,
    })
  end

  local function get_buffer_dir()
    local cwd = vim.fn.expand('%:h')
    if cwd == "" then
      cwd = vim.fn.getcwd()
    end
    local home = vim.fn.getenv('HOME')
    return string.gsub(cwd, home, '~')
  end

  local function set_prompt_border_color(color)
    vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { fg = color })
  end

  local function prompt_with_cwd(prompt)
    return prompt .. ' 󰉖 ' .. utils.get_short_cwd()
  end

  -- returns true if the current buffer has an LSP client attached to it
  local function has_lsp_client_attached()
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
      vim.notify('no lsp clients attached to current buffer', vim.log.levels.WARN, { title = "Telescope" })
      return false
    end
    return true
  end

  --
  -- Restore TelescopePromptBorder highlight
  --
  local group = vim.api.nvim_create_augroup('cfg#plugin#telescope', { clear = true })

  local function restore_original_prompt_border()
    if vim.o.filetype == 'TelescopePrompt' then
      -- reset the telescope prompt border color once we close telescope
      vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { link = 'TelescopeBorder' })
    end
  end

  vim.api.nvim_create_autocmd('BufLeave', {
    group = group,
    desc = 'Restore original telescope prompt border',
    callback = restore_original_prompt_border,
  })

  --
  -- Custom pickers
  --

  -- Searches for files under the directory of the current buffer
  local function cwd_files()
    set_prompt_border_color('#22ee22')
    local cwd = get_buffer_dir()
    builtin.find_files {
      cwd = cwd,
      hidden = true,
      prompt_title = "Files 󰉖  " .. cwd,
    }
  end

  local function change_cwd()
    builtin.find_files {
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          vim.cmd('lcd ' .. action_state.get_selected_entry()[1])
        end)
        return true
      end,
      find_command = { "fd", "--type", "d", "--hidden" },
      prompt_title = 'Change cwd of window',
    }
  end

  -- Searches for all files, including hidden and git ignored files. Useful when
  -- I'm working on my dotfiles for example, since sometimes I want to open a
  -- file that's in an external vim plugin which is under a path that's in a
  -- .gitignore.
  local function find_all_files()
    set_prompt_border_color('#bb2222')
    builtin.find_files {
      find_command = { "fd", "--type", "f", "--hidden", "--no-ignore-vcs" },
      prompt_title = prompt_with_cwd("Files [no ignore]")
    }
  end

  local function with_git_root(callback)
    local git_root, ret = tutils.get_os_command_output({ "git", "rev-parse", "--show-toplevel" }, vim.fn.getcwd())
    if ret == 0 and git_root and git_root[1] ~= nil then
      return callback(git_root[1])
    end
    vim.notify('Not in a git repo', vim.log.levels.WARN, { title = "Telescope" })
    return nil
  end

  -- Searches by using the builtin find_files picker
  local function git_files()
    set_prompt_border_color('#eeff00')
    with_git_root(function(git_root)
      local path = utils.collapse_home_path_to_tilde(git_root)
      builtin.git_files({ prompt_title = "  files 󰉖 " .. path })
    end)
  end

  local function action_post_change_cwd(change_win_cwd)
    if change_win_cwd then
      local selection = action_state.get_selected_entry()
      local file_dir = vim.fn.fnamemodify(selection[1], ':h')
      vim.cmd('lcd ' .. file_dir)
    end
  end

  local function change_win_cwd_mappings(_, map)
    local change_win_cwd = false
    map('i', '<M-c>', function(_prompt_bufnr)
      local picker = action_state.get_current_picker(_prompt_bufnr)
      local original_title = picker.prompt_title
      change_win_cwd = not change_win_cwd
      if change_win_cwd then
        picker.prompt_border:change_title(picker.prompt_title .. '   ')
      else
        picker.prompt_border:change_title(original_title)
      end
    end)
    action_set.select:enhance {
      post = function() action_post_change_cwd(change_win_cwd) end,
    }
    -- needs to return true if you want to map default_mappings and
    -- false if not
    return true
  end

  -- Searches by using the builtin find_files picker
  local function find_files()
    set_prompt_border_color('#eeff00')
    builtin.find_files {
      find_command = { "fd", "--type", "f" },
      prompt_title = prompt_with_cwd("Files"),
      hidden = true,
      attach_mappings = change_win_cwd_mappings,
    }
  end

  local function find_buffers()
    builtin.buffers {
      attach_mappings = function(_, map)
        map(
          { 'i', 'n' },
          '<C-d>',
          function(prompt_bufnr)
            actions.delete_buffer(prompt_bufnr)
          end,
          { desc = 'Delete buffer' })
        return true
      end,
    }
  end

  -- Search workspace LSP symbols but checks if there's an LSP client attached
  -- to the current buffer first. If there isn't, it's a no-op.
  local function lsp_dynamic_workspace_symbols()
    if has_lsp_client_attached() then
      return builtin.lsp_dynamic_workspace_symbols()
    end
  end

  local function live_grep_everything()
    -- set telescope prompt border to red
    set_prompt_border_color('#bb2222')
    builtin.live_grep {
      prompt_title = prompt_with_cwd("Live Grep all the things"),
      additional_args = function() return { "--no-ignore-vcs" } end
    }
  end

  local function live_grep_dir_of_current_buffer()
    set_prompt_border_color('#22ee22')
    local cwd = get_buffer_dir()
    builtin.live_grep {
      cwd = cwd,
      prompt_title = "Live Grep 󰉖 " .. cwd,
    }
  end

  local function live_grep_workspace()
    set_prompt_border_color('#eeff00')
    builtin.live_grep {
      prompt_title = prompt_with_cwd("Live Grep"),
    }
  end

  local function live_grep_git_root()
    set_prompt_border_color('#bb2222')
    with_git_root(function(git_root)
      local path = utils.collapse_home_path_to_tilde(git_root)
      builtin.live_grep({
        cwd = git_root,
        prompt_title = "   Live Grep 󰉖 " .. path
      })
    end)
  end

  -- Wrapper to check if there's an LSP client attached to the current buffer
  -- before invoking builtin.lsp_references
  local function lsp_references()
    if has_lsp_client_attached() then
      return builtin.lsp_references()
    end
  end

  local function spell_suggestions()
    builtin.spell_suggest(themes.get_cursor({}))
  end

  local function setup_mappings()
    which_key.add({
      -- Files
      { "<leader>f", group = "Files" },
      { "<leader>fa", find_all_files, desc = 'All files (including hidden)' },
      { "<leader>fd", cwd_files, desc = 'Dir of current buffer' },
      { "<leader>fe", find_files, desc = 'Workspace' },
      { "<leader>fg", git_files, desc = '  files' },
      { "<leader>fr", builtin.oldfiles, desc = 'Recent files' },

      -- Grep
      { "<leader>g", group = "Grep" },
      { "<leader>ga", live_grep_everything, desc = "Workspace (all, without ignore)" },
      { "<leader>gd", live_grep_dir_of_current_buffer, desc = "Dir of current buffer" },
      { "<leader>ge", live_grep_workspace, desc = "Workspace" },
      { "<leader>gg", live_grep_git_root, desc = "Git root" },

      -- LSP
      { "<leader>l", group = "LSP" },
      { "<leader>ll", lsp_dynamic_workspace_symbols, desc = "Dynamic workspace symbols" },
      { "<leader>ls", builtin.lsp_document_symbols, desc = "Document symbols" },
      { "<leader>lr", lsp_references, desc = "References" },

      -- Telescope
      { "<leader>t", group = "Telescope" },
      { "<leader>t*", builtin.current_buffer_fuzzy_find, desc = "Current buffer fuzzy find" },
      { "<leader>tb", builtin.buffers, desc = "Buffers" },
      { "<leader>tc", change_cwd, desc = "Change CWD of current window" },
      { "<leader>th", builtin.help_tags, desc = "Help tags" },
      { "<leader>tt", '<cmd>Telescope<CR>', desc = "Show available pickers" },

      -- Misc
      { "<leader>bb", find_buffers, desc = "Search buffers" },
      { "<leader>/", builtin.current_buffer_fuzzy_find, desc = "Current buffer fuzzy find" },
      { "z=", spell_suggestions, desc = "Show spelling suggestions for word under cursor" },
    })
  end

  setup_mappings()

  require('telescope').setup {
    defaults = {
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--glob",
        "!.git",
      },
      dynamic_preview_title = true,
      prompt_prefix = "  ",
      selection_caret = "󰁕 ",
      path_display = { "truncate" },
      winblend = 20,
      color_devicons = true,
      preview = {
        -- 1) Do not show previewer for certain files
        filetype_hook = function(filepath, bufnr, opts)
          local excluded = vim.tbl_filter(function(ending)
            return filepath:match(ending)
          end, {
            "pnpm%-lock%.yaml",
          })
          if not vim.tbl_isempty(excluded) then
            return false
          end
          return true
        end,
      },
      layout_strategy = "flex",
      layout_config = {
        width = 0.90,
        height = 0.90,
        flex = {
          flip_columns = 160,
        },
        horizontal = {
          prompt_position = "bottom",
          preview_width = 0.45,
        },
        vertical = {
          preview_height = 0.25,
          preview_cutoff = 1,
        }
      },
      border = {},
      borderchars = {
        { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        prompt  = { "─", "│", "─", "│", "╔", "╗", "╝", "╚" },
        results = { "─", "│", "─", "│", "╔", "╗", "╝", "╚" },
        preview = { "─", "│", "─", "│", "╔", "╗", "╝", "╚" },
      },
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      -- Developer configurations: Not meant for general override
      buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
      mappings = {
        i = {
          ["<C-n>"] = actions.cycle_history_next,
          ["<C-p>"] = actions.cycle_history_prev,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-c>"] = actions.close,
          ["<Down>"] = actions.move_selection_next,
          ["<Up>"] = actions.move_selection_previous,
          ["<CR>"] = actions.select_default + actions.center,
          ["<C-x>"] = actions.select_horizontal,
          ["<C-v>"] = actions.select_vertical,
          ["<C-t>"] = actions.select_tab,
          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          ["<PageUp>"] = actions.results_scrolling_up,
          ["<PageDown>"] = actions.results_scrolling_down,
          ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
          ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
          ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
          ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          ["<C-l>"] = actions.complete_tag,
          ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
        },
        n = {
          ["<esc>"] = actions.close,
          ["q"] = actions.close,
          ["<CR>"] = actions.select_default,
          ["<C-x>"] = actions.select_horizontal,
          ["<C-v>"] = actions.select_vertical,
          ["<C-t>"] = actions.select_tab,
          ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
          ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
          ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
          ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          ["j"] = actions.move_selection_next,
          ["k"] = actions.move_selection_previous,
          ["H"] = actions.move_to_top,
          ["M"] = actions.move_to_middle,
          ["L"] = actions.move_to_bottom,
          ["<Down>"] = actions.move_selection_next,
          ["<Up>"] = actions.move_selection_previous,
          ["gg"] = actions.move_to_top,
          ["G"] = actions.move_to_bottom,
          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          ["<PageUp>"] = actions.results_scrolling_up,
          ["<PageDown>"] = actions.results_scrolling_down,
          ["?"] = actions.which_key,
        },
      },
    },
    pickers = {
      -- Default configuration for builtin pickers goes here:
      -- picker_name = {
      --   picker_config_key = value,
      --   ...
      -- }
      -- Now the picker_config_key will be applied every time you call this
      -- builtin picker
      lsp_definitions = {
        fname_width = 100,
        layout_strategy = 'vertical',
      },
      lsp_document_symbols = {
        layout_strategy = 'vertical',
        symbol_width = 50
      },
      lsp_dynamic_workspace_symbols = {
        layout_strategy = 'vertical',
        fname_width = 100,
        symbol_width = 70,
      },
      lsp_implementations = {
        fname_width = 100,
        layout_strategy = 'vertical',
      },
      lsp_incoming_calls = {
        fname_width = 100,
        layout_strategy = 'vertical',
      },
      lsp_outgoing_calls = {
        fname_width = 100,
        layout_strategy = 'vertical',
      },
      lsp_references = {
        fname_width = 60,
        layout_strategy = 'vertical',
      },
      lsp_type_definitions = {
        fname_width = 60,
        layout_strategy = 'vertical',
      },
      lsp_workspace_symbols = {
        fname_width = 60,
        layout_strategy = 'vertical',
      },
    },
    extensions = {
      ["ui-select"] = { require("telescope.themes").get_dropdown() },
      fzf = {
        --[[
        | Token     | Match type                 | Description                          |
        | --------- | -------------------------- | ------------------------------------ |
        | `sbtrkt`  | fuzzy-match                | Items that match `sbtrkt`            |
        | `'wild`   | exact-match (quoted)       | Items that include `wild`            |
        | `^music`  | prefix-exact-match         | Items that start with `music`        |
        | `.mp3$`   | suffix-exact-match         | Items that end with `.mp3`           |
        | `!fire`   | inverse-exact-match        | Items that do not include `fire`     |
        | `!^music` | inverse-prefix-exact-match | Items that do not start with `music` |
        | `!.mp3$`  | inverse-suffix-exact-match | Items that do not end with `.mp3`    |
        ]]
        fuzzy = true,                   -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
      themes = {},
      terms = {}
    },
  }
end

return {
  {
    -- requires git, fd, ripgrep
    'nvim-telescope/telescope.nvim',
    enabled = false,
    config = config,
    dependencies = {
      'which-key.nvim',
      'nvim-tree/nvim-web-devicons',
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
    },
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    enabled = false,
    build = 'make',
    config = function()
      require('telescope').load_extension 'fzf'
    end,
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    enabled = false,
    config = function()
      require('telescope').load_extension('ui-select')
    end,
  }
}
