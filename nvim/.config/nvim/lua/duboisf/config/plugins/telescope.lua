local M = {}

local telescope = require'telescope'
local previewers = require 'telescope.previewers'
local builtin = require 'telescope.builtin'

local nmap = function (lhs, rhs)
  vim.keymap.set("n", lhs, rhs, {
    silent = true,
    noremap = true,
  })
end

nmap('<leader>fc', function() builtin.commands() end)
nmap('<leader>fe', function() M.project_files() end)
nmap('<leader>fd', function() M.cwd_files() end)
nmap('<leader>fs', function() builtin.lsp_document_symbols() end)
nmap('<leader>fw', function()
  local clients = vim.lsp.buf_get_clients(0)
  if #clients > 0 then
    return builtin.lsp_dynamic_workspace_symbols()
  end
  vim.notify('no lsp clients attached to current buffer', vim.log.levels.WARN)
end)
nmap('<leader>f*', function() builtin.current_buffer_fuzzy_find() end)
nmap('<leader>fgg',function() builtin.live_grep { cwd = vim.fn.expand('%:h') } end)
nmap('<leader>fgw',function() builtin.live_grep() end)
nmap('<leader>fb', function() builtin.buffers() end)
nmap('<leader>fh', function() builtin.help_tags() end)
nmap('<leader>fr', function() builtin.oldfiles() end)

require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
    },
    prompt_prefix = "🔎 ",
    selection_caret = "👉 ",
    entry_prefix = "   ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "vertical",
    layout_config = {
      horizontal = {
        mirror = false,
      },
      vertical = {
        mirror = false,
      },
    },
    file_sorter = require 'telescope.sorters'.get_fzy_sorter,
    file_ignore_patterns = {},
    generic_sorter = require 'telescope.sorters'.get_fzy_sorter,
    winblend = 20,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    -- color_devicons = true,
    use_less = true,
    -- path_display = { 'smart' },
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
    -- file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require 'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require 'telescope.previewers'.vim_buffer_qflist.new,

    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require 'telescope.previewers'.buffer_previewer_maker
  }
}

require'telescope'.load_extension 'fzf'

function M.cwd_files(opts)
  local cwd = vim.fn.expand('%:h')
  if cwd == "" then
    cwd = vim.fn.getcwd()
  end
  require('telescope.builtin').find_files({ cwd = cwd, hidden = true })
end

function M.project_files(opts)
  local opts = opts or {}
  local ok = pcall(require 'telescope.builtin'.git_files, opts)
  if not ok then
    require 'telescope.builtin'.find_files(opts)
  end
end

function M.document_symbols()
  local input = vim.fn.input('Query: ')
  if input == '' then
    return
  end
  require 'telescope.builtin'.lsp_workspace_symbols()
end

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

return M
