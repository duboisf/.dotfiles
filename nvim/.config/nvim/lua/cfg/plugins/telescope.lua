local actions = require "telescope.actions"
local builtin = require 'telescope.builtin'
local utils = require 'core.utils'
local tutils = require "telescope.utils"

local nmap = function(lhs, rhs)
  vim.keymap.set("n", lhs, rhs, {
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
  return prompt .. '  ' .. utils.get_short_cwd()
end

-- returns true if the current buffer has an LSP client attached to it
local function has_lsp_client_attached()
  local clients = vim.lsp.buf_get_clients(0)
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
  builtin.find_files({
    cwd = cwd, hidden = true,
    prompt_title = "Files   " .. cwd,
  })
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

-- Searches by using the builtin find_files picker
local function git_files()
  set_prompt_border_color('#eeff00')
  local git_root, ret = tutils.get_os_command_output({ "git", "rev-parse", "--show-toplevel" }, vim.fn.getcwd())
  if ret == 0 and git_root and git_root[1] ~= nil then
    local path = utils.collapse_home_path_to_tilde(git_root[1])
    builtin.git_files({ prompt_title = "  files  " .. path })
  else
    vim.notify('Not in a git repo', vim.log.levels.WARN, { title = "Telescope" })
  end
end

-- Searches by using the builtin find_files picker
local function find_files()
  set_prompt_border_color('#eeff00')
  builtin.find_files {
    prompt_title = prompt_with_cwd("Files"),
    hidden = true,
  }
end

-- Searche workspace LSP symbols but checks if there's an LSP client attached
-- to the current buffer first. If there isn't, notifies me instead of throwing
-- an error.
local function lsp_dynamic_workspace_symbols()
  if has_lsp_client_attached() then
    return builtin.lsp_dynamic_workspace_symbols()
  end
end

local function live_grep_everything()
  -- set telescope prompt border to red
  set_prompt_border_color('#bb2222')
  builtin.live_grep {
    prompt_title = prompt_with_cwd("Live Grep [all the things]"),
    additional_args = function() return { "--no-ignore-vcs" } end
  }
end

local function live_grep_dir_of_current_buffer()
  set_prompt_border_color('#22ee22')
  local cwd = get_buffer_dir()
  builtin.live_grep {
    cwd = cwd,
    prompt_title = "Live Grep  " .. cwd,
  }
end

local function live_grep_workspace()
  set_prompt_border_color('#eeff00')
  builtin.live_grep {
    prompt_title = prompt_with_cwd("Live Grep")
  }
end

-- Wrapper to check if there's an LSP client attache to the current buffer
-- before invoking builtin.lsp_references
local function lsp_references()
  if has_lsp_client_attached() then
    return builtin.lsp_references()
  end
end

local function setup_mappings()
  nmap('gr', lsp_references)
  nmap('<leader>ff', ':Telescope<CR>')
  nmap('<leader>fa', git_files)
  nmap('<leader>fe', find_files)
  nmap('<leader>fd', cwd_files)
  nmap('<leader>fs', builtin.lsp_document_symbols)
  nmap('<leader>fw', lsp_dynamic_workspace_symbols)
  nmap('<leader>f*', builtin.current_buffer_fuzzy_find)
  nmap('<leader>fga', live_grep_everything)
  nmap('<leader>fgd', live_grep_dir_of_current_buffer)
  nmap('<leader>fgw', live_grep_workspace)
  nmap('<leader>fb', builtin.buffers)
  nmap('<leader>fh', builtin.help_tags)
  nmap('<leader>fr', builtin.oldfiles)
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
    },
    prompt_prefix = "  ",
    selection_caret = " ",
    path_display = { "truncate" },
    winblend = 20,
    color_devicons = true,
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "bottom",
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
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
        ["<esc>"] = actions.close,
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,

        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<C-c>"] = actions.close,

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,

        ["<CR>"] = actions.select_default,
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
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {
        -- even more opts
        width = 0.8,
        previewer = false,
        prompt_title = false,
        borderchars = {
          { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
          preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
      }
    },
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
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    themes = {},
    terms = {}
  },
  preview = {
  }
}

-- do
--   local curl = require 'plenary.curl'
--   local asana = io.open('/home/fred/.asana')
--   if asana then
--     local token = asana:read('*a')
--     asana:close()
--   end

--   local function join(list, sep)
--     local cumul = ""
--     sep = sep or ""
--     local sep2 = ""
--     for _, elem in ipairs(list) do
--       cumul = cumul .. sep2 .. elem
--       sep2 = sep or ""
--     end
--     return cumul
--   end

--   local function asana_entry_maker(task)
--     return {
--       display = task.name,
--       ordinal = task.name,
--       gid = task.gid,
--       preview_command = function(entry, bufnr)
--         vim.fn.appendbufline(bufnr, 0, entry.description)
--       end,
--       value = task.permalink_url,
--     }
--   end

--   local function recent_tasks(opts)
--     -- local current_date = vim.fn.trim(vim.fn.system('date --date="7 days ago" +%Y-%m-%d'))
--     local url = join {
--       'https://app.asana.com/api/1.0/tasks?',
--       join({
--         'workspace=14435158881936',
--         'completed_since=now',
--         -- 'modified_since=' .. current_date .. 'T00:00:00Z',
--         'assignee=' .. opts.username,
--         'opt_fields=name,permalink_url',
--       },
--         '&'
--       )
--     }
--     local result = curl.get {
--       url = url,
--       accept_header = 'application/json',
--       headers = { Authorization = 'Bearer ' .. token },
--     }
--     if result.status == 200 then
--       local tasks = vim.fn.json_decode(result.body).data
--       return tasks
--     end
--     return {}
--   end

--   local actions = require "telescope.actions"
--   local conf = require("telescope.config").values
--   local finders = require "telescope.finders"
--   local pickers = require "telescope.pickers"

--   local action_set = require "telescope.actions.set"
--   local action_state = require "telescope.actions.state"

--   local function action_print_asana(callback)
--     return function(prompt_bufnr)
--       local value = action_state.get_selected_entry().value
--       actions.close(prompt_bufnr)
--       callback(value)
--     end
--   end

--   local function default_asana_callback(value)
--     local line = vim.fn.getline('.')
--     local col = vim.fn.col('.')
--     local markdown_link = '[Asana task](' .. value .. '/f)'
--     vim.fn.setline('.', string.sub(line, 1, col) .. markdown_link .. string.sub(line, col))
--   end

--   function M.asana_tasks(opts)
--     local opts = opts or {}
--     opts.callback = opts.callback or default_asana_callback
--     assert(type(opts.callback) == 'function')
--     assert(opts.username, 'must supply asana username in opts.username')
--     pickers.new(opts, {
--       prompt_title = "Asana tasks",
--       finder = finders.new_table {
--         results = recent_tasks(opts),
--         entry_maker = asana_entry_maker,
--       },
--       -- previewer = previewers.new_buffer_previewer {
--       --   title = "Asana Task Preview",
--       --   dyn_title = function(_, entry)
--       --     return entry.display
--       --   end,

--       --   get_buffer_by_name = function(_, entry)
--       --     return entry.gid
--       --   end,

--       --   define_preview = function(self, entry, status)
--       --     local markdown_link = '[Asana task](' .. entry.value .. '/f)'
--       --     local err = vim.fn.setbufline(self.state.bufnr, 1, markdown_link)
--       --     local url = 'https://app.asana.com/api/1.0/tasks/' .. entry.gid
--       --     local result = curl.get {
--       --       url = url,
--       --       accept_header = 'application/json',
--       --       headers = { Authorization = 'Bearer ' .. token },
--       --     }
--       --     local notes = ''
--       --     local data = {}
--       --     if result.status == 200 then
--       --       local data = vim.fn.json_decode(result.body).data
--       --       notes = data.notes
--       --     else
--       --       notes = 'Could not get notes for task ' .. entry.gid
--       --     end
--       --     dump(data)
--       --     local err = vim.fn.setbufline(self.state.bufnr, 1, notes)
--       --     if err ~= 0 then
--       --       print('could not setbufline for buffer ' .. self.state.bufnr)
--       --     end
--       --   end,
--       -- },
--       sorter = conf.file_sorter(opts),
--       attach_mappings = function()
--         action_set.select:replace(action_print_asana(opts.callback))
--         return true
--       end,
--     }):find()
--   end
-- end
