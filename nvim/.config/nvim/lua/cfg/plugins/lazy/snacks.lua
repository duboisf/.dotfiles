-- Just to make lazydev load the type annotations
pcall(require, "snacks")

local function search_dotfiles()
  Snacks.picker.files({
    cwd = vim.env.HOME .. "/.dotfiles",
    hidden = true,
    prompt_title = "Search my .[d]otfiles",
    previewer = true,
  })
end

vim.keymap.set("i", "<C-CR>", function() print("pressed Ctrl+Shift+Enter") end, { desc = "Ctrl+Shift+Enter" })

--- Get the directory of the current buffer
local function get_current_buf_dir()
  return vim.fn.expand("%:p:h")
end


---@type LazyPluginSpec
return {
  "folke/snacks.nvim",
  lazy = false,
  ---@type snacks.Config
  opts = {
    input = {},
    picker = {},
    explorer = {
      replace_netrw = false,
    },
  },
  keys = {
    -- List pickers
    { "<leader>a",       function() Snacks.picker() end,                                                      desc = "List Pickers" },
    -- Custom
    { ",d",              search_dotfiles,                                                                     desc = "Find my dotfiles" },
    { "<leader>fd",      function() Snacks.picker.files({ cwd = get_current_buf_dir() }) end,                 desc = "Find files in directory of current file" },
    { "<leader>gd",      function() Snacks.picker.grep({ args = { "-i" }, cwd = get_current_buf_dir() }) end, desc = "Grep files in directory of current file" },
    { "<leader>gg",      function() Snacks.picker.grep({ args = { "-i" }, need_search = false }) end,         desc = "Grep files" },
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end,                                                desc = "Smart Find Files" },
    { "<leader>,",       function() Snacks.picker.buffers() end,                                              desc = "Buffers" },
    { "<leader>/",       function() Snacks.picker.lines() end,                                                desc = "Grep" },
    { "<leader>:",       function() Snacks.picker.command_history() end,                                      desc = "Command History" },
    { "<leader>n",       function() Snacks.picker.notifications() end,                                        desc = "Notification History" },
    { "<leader>e",       function() Snacks.explorer() end,                                                    desc = "File Explorer" },
    -- find
    { "<leader><Tab>",   function() Snacks.picker.buffers() end,                                              desc = "Buffers" },
    { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,              desc = "Find Config File" },
    { "<leader>fe",      function() Snacks.picker.files() end,                                                desc = "Find Files" },
    { "<leader>fg",      function() Snacks.picker.git_files() end,                                            desc = "Find Git Files" },
    { "<leader>fp",      function() Snacks.picker.projects() end,                                             desc = "Projects" },
    { "<leader>fr",      function() Snacks.picker.recent() end,                                               desc = "Recent" },
    -- git
    { "<leader>gb",      function() Snacks.picker.git_branches() end,                                         desc = "Git Branches" },
    { "<leader>gl",      function() Snacks.picker.git_log() end,                                              desc = "Git Log" },
    { "<leader>gL",      function() Snacks.picker.git_log_line() end,                                         desc = "Git Log Line" },
    { "<leader>gs",      function() Snacks.picker.git_status() end,                                           desc = "Git Status" },
    { "<leader>gS",      function() Snacks.picker.git_stash() end,                                            desc = "Git Stash" },
    -- { "<leader>gd",      function() Snacks.picker.git_diff() end,                                desc = "Git Diff (Hunks)" },
    { "<leader>gf",      function() Snacks.picker.git_log_file() end,                                         desc = "Git Log File" },
    -- Grep
    { ",sb",             function() Snacks.picker.lines() end,                                                desc = "Buffer Lines" },
    { ",sB",             function() Snacks.picker.grep_buffers() end,                                         desc = "Grep Open Buffers" },
    { ",sg",             function() Snacks.picker.grep() end,                                                 desc = "Grep" },
    { ",sW",             function() Snacks.picker.grep_word() end,                                            desc = "Visual selection or word",               mode = { "n", "x" } },
    -- search
    { ',s"',             function() Snacks.picker.registers() end,                                            desc = "Registers" },
    { ',s/',             function() Snacks.picker.search_history() end,                                       desc = "Search History" },
    { ",sa",             function() Snacks.picker.autocmds() end,                                             desc = "Autocmds" },
    { ",sb",             function() Snacks.picker.lines() end,                                                desc = "Buffer Lines" },
    { ",sc",             function() Snacks.picker.command_history() end,                                      desc = "Command History" },
    { ",sC",             function() Snacks.picker.commands() end,                                             desc = "Commands" },
    { ",sd",             function() Snacks.picker.diagnostics({ filter = { buf = nil } }) end,                desc = "Diagnostics" },
    { ",sD",             function() Snacks.picker.diagnostics_buffer() end,                                   desc = "Buffer Diagnostics" },
    { ",sh",             function() Snacks.picker.help() end,                                                 desc = "Help Pages" },
    { ",sH",             function() Snacks.picker.highlights() end,                                           desc = "Highlights" },
    { ",si",             function() Snacks.picker.icons() end,                                                desc = "Icons" },
    { ",sj",             function() Snacks.picker.jumps() end,                                                desc = "Jumps" },
    { ",sk",             function() Snacks.picker.keymaps() end,                                              desc = "Keymaps" },
    { ",sl",             function() Snacks.picker.loclist() end,                                              desc = "Location List" },
    { ",sm",             function() Snacks.picker.marks() end,                                                desc = "Marks" },
    { ",sM",             function() Snacks.picker.man() end,                                                  desc = "Man Pages" },
    { ",sp",             function() Snacks.picker.lazy() end,                                                 desc = "Search for Plugin Spec" },
    { ",sq",             function() Snacks.picker.qflist() end,                                               desc = "Quickfix List" },
    { ",sR",             function() Snacks.picker.resume() end,                                               desc = "Resume" },
    { ",su",             function() Snacks.picker.undo() end,                                                 desc = "Undo History" },
    { "<leader>uC",      function() Snacks.picker.colorschemes() end,                                         desc = "Colorschemes" },
    -- LSP
    { "gd",              function() Snacks.picker.lsp_definitions() end,                                      desc = "Goto Definition" },
    { "gD",              function() Snacks.picker.lsp_declarations() end,                                     desc = "Goto Declaration" },
    { "grr",             function() Snacks.picker.lsp_references() end,                                       nowait = true,                                   desc = "References" },
    { "gri",             function() Snacks.picker.lsp_implementations() end,                                  desc = "Goto Implementation" },
    { "gy",              function() Snacks.picker.lsp_type_definitions() end,                                 desc = "Goto T[y]pe Definition" },
    { "<leader>ls",      function() Snacks.picker.lsp_symbols() end,                                          desc = "LSP Symbols" },
    { "<leader>lw",      function() Snacks.picker.lsp_workspace_symbols() end,                                desc = "LSP Workspace Symbols" },
  },
}
