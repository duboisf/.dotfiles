---@module 'snacks'

local function get_git_root()
  local obj = vim.system({ "git", "rev-parse", "--show-toplevel" }):wait()
  if obj.code ~= 0 then
    vim.notify("Not in a git repo", vim.log.levels.WARN)
    return nil
  end
  return vim.fn.trim(obj.stdout)
end

local function files_in_git_root()
  local git_root = get_git_root()
  if git_root then
    Snacks.picker.files({
      cwd = git_root,
      hidden = true,
    })
  end
end

local function search_dotfiles()
  Snacks.picker.files({
    cwd = vim.env.HOME .. "/.dotfiles",
    hidden = true,
    prompt_title = "Search my .[d]otfiles",
    previewer = true,
  })
end

local function find_lazy_plugin_files()
  local data_path = vim.fn.stdpath('data')
  local lazy_plugins = vim.fs.joinpath(data_path, 'lazy')
  Snacks.picker.files({
    dirs = { lazy_plugins },
    title = "Lazy plugins",
  })
end

--- Get the directory of the current buffer
local function get_current_buf_dir()
  return vim.fn.expand("%:p:h")
end

local function grep_cwd()
  Snacks.picker.grep({
    args = { "-i", "-." },
    need_search = false
  })
end

local function grep_current_file_directory()
  Snacks.picker.grep({
    args = { "-i", "-." },
    need_search = false,
    cwd =
        get_current_buf_dir()
  })
end

---@type LazyPluginSpec
return {
  "folke/snacks.nvim",
  lazy = false,
  ---@type snacks.Config
  opts = {
    input = {},
    picker = {
      formatters = {
        file = {
          truncate = 200,
        },
      },
      sources = {
        files = {
          hidden = true,
        },
        grep = {
          hidden = true,
        },
      },
    },
    explorer = {
      replace_netrw = false,
    },
  },
  keys = {
    -- List pickers
    { "<leader>a",       function() Snacks.picker() end,                                         desc = "List Pickers" },
    -- Custom
    { ",d",              search_dotfiles,                                                        desc = "Find my dotfiles" },
    { "<leader>fa",      function() files_in_git_root() end,                                     desc = "Find Config File" },
    { "<leader>fd",      function() Snacks.picker.files({ cwd = get_current_buf_dir() }) end,    desc = "Find files in directory of current file" },
    { "<leader>gd",      grep_current_file_directory,                                            desc = "Grep files in directory of current file" },
    { "<leader>gg",      grep_cwd,                                                               desc = "Grep files" },
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
    { "<leader>,",       function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
    { "<leader>/",       function() Snacks.picker.lines() end,                                   desc = "Grep" },
    { "<leader>:",       function() Snacks.picker.command_history() end,                         desc = "Command History" },
    { "<leader>n",       function() Snacks.picker.notifications() end,                           desc = "Notification History" },
    { "<leader>e",       function() Snacks.explorer() end,                                       desc = "File Explorer" },
    -- find
    { "<leader><Tab>",   function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
    { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    { "<leader>fe",      function() Snacks.picker.files() end,                                   desc = "Find Files" },
    { "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
    { "<leader>fl",      function() find_lazy_plugin_files() end,                                desc = "Find Lazy Plugin Files" },
    { "<leader>fp",      function() Snacks.picker.projects() end,                                desc = "Projects" },
    { "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "Recent" },
    -- git
    { "<leader>gb",      function() Snacks.picker.git_branches() end,                            desc = "Git Branches" },
    { "<leader>gl",      function() Snacks.picker.git_log() end,                                 desc = "Git Log" },
    { "<leader>gL",      function() Snacks.picker.git_log_line() end,                            desc = "Git Log Line" },
    { "<leader>gs",      function() Snacks.picker.git_status() end,                              desc = "Git Status" },
    { "<leader>gS",      function() Snacks.picker.git_stash() end,                               desc = "Git Stash" },
    -- { "<leader>gd",      function() Snacks.picker.git_diff() end,                                desc = "Git Diff (Hunks)" },
    { "<leader>gf",      function() Snacks.picker.git_log_file() end,                            desc = "Git Log File" },
    -- Grep
    { "<leader>wb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
    { "<leader>wB",      function() Snacks.picker.grep_buffers() end,                            desc = "Grep Open Buffers" },
    { "<leader>wg",      function() Snacks.picker.grep() end,                                    desc = "Grep" },
    { "<leader>wW",      function() Snacks.picker.grep_word() end,                               desc = "Visual selection or word",               mode = { "n", "x" } },
    -- search
    { '<leader>w"',      function() Snacks.picker.registers() end,                               desc = "Registers" },
    { '<leader>w/',      function() Snacks.picker.search_history() end,                          desc = "Search History" },
    { "<leader>wa",      function() Snacks.picker.autocmds() end,                                desc = "Autocmds" },
    { "<leader>wb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
    { "<leader>wc",      function() Snacks.picker.command_history() end,                         desc = "Command History" },
    { "<leader>wC",      function() Snacks.picker.commands() end,                                desc = "Commands" },
    { "<leader>wd",      function() Snacks.picker.diagnostics({ filter = { buf = nil } }) end,   desc = "Diagnostics" },
    { "<leader>wD",      function() Snacks.picker.diagnostics_buffer() end,                      desc = "Buffer Diagnostics" },
    { "<leader>wh",      function() Snacks.picker.help() end,                                    desc = "Help Pages" },
    { "<leader>wH",      function() Snacks.picker.highlights() end,                              desc = "Highlights" },
    { "<leader>wi",      function() Snacks.picker.icons() end,                                   desc = "Icons" },
    { "<leader>wj",      function() Snacks.picker.jumps() end,                                   desc = "Jumps" },
    { "<leader>wk",      function() Snacks.picker.keymaps() end,                                 desc = "Keymaps" },
    { "<leader>wl",      function() Snacks.picker.loclist() end,                                 desc = "Location List" },
    { "<leader>wm",      function() Snacks.picker.marks() end,                                   desc = "Marks" },
    { "<leader>wM",      function() Snacks.picker.man() end,                                     desc = "Man Pages" },
    { "<leader>wp",      function() Snacks.picker.lazy() end,                                    desc = "Search for Plugin Spec" },
    { "<leader>wq",      function() Snacks.picker.qflist() end,                                  desc = "Quickfix List" },
    { "<leader>wR",      function() Snacks.picker.resume() end,                                  desc = "Resume" },
    { "<leader>wu",      function() Snacks.picker.undo() end,                                    desc = "Undo History" },
    -- LSP
    { "gd",              function() Snacks.picker.lsp_definitions() end,                         desc = "Goto Definition" },
    { "gD",              function() Snacks.picker.lsp_declarations() end,                        desc = "Goto Declaration" },
    { "grr",             function() Snacks.picker.lsp_references() end,                          nowait = true,                                   desc = "References" },
    { "gri",             function() Snacks.picker.lsp_implementations() end,                     desc = "Goto Implementation" },
    { "gy",              function() Snacks.picker.lsp_type_definitions() end,                    desc = "Goto T[y]pe Definition" },
    { ",s",              function() Snacks.picker.lsp_symbols() end,                             desc = "LSP Symbols" },
    { ",w",              function() Snacks.picker.lsp_workspace_symbols() end,                   desc = "LSP Workspace Symbols" },
  },
}
