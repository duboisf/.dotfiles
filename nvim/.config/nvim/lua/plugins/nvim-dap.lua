local launchTemplate = [[{
    "\$schema": "https://raw.githubusercontent.com/mfussenegger/dapconfig-schema/master/dapconfig-schema.json",
    "version": "0.2.0",
    "configurations": [
        {
            "type": "${1:go}",
            "request": "${2|launch,attach|}",
            "program": "${3:\${workspaceFolder}}",
            "name": "${4:Launch main}",
            "args": []${0}
        }
    ]
}]]

local function create_autocmds()
  -- Remove existing dap autocommand to define my own
  vim.api.nvim_del_augroup_by_name('dap-launch.json')

  local group = vim.api.nvim_create_augroup('duboisf.dap', { clear = true })

  vim.api.nvim_create_autocmd('BufNewFile', {
    group = group,
    pattern = '*/.vscode/launch.json',
    callback = function(args)
      vim.api.nvim_buf_call(args.buf, function()
        vim.snippet.expand(launchTemplate)
      end)
    end,
    desc = 'Insert launch.json template when creating a new one',
  })

  -- Disable blink completion in dap-repl and dapui buffers
  vim.api.nvim_create_autocmd('Filetype', {
    group = group,
    pattern = { 'dap-repl', 'dapui*' },
    callback = function()
      vim.b.completion = false
    end,
  })

  vim.api.nvim_create_autocmd('Filetype', {
    group = group,
    pattern = 'dap-float',
    callback = function(args)
      vim.keymap.set('n', 'q', vim.cmd.close, { buffer = args.buf, silent = true })
    end,
  })
end

---Get the list of main files in the current Go project using gopls
---@return string?, string[] error message or list of main files
local function find_main_files()
  local clients = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })
  if vim.tbl_isempty(clients) then
    return "gopls isn't attached to the buffer", {}
  end
  local gopls = clients[1]
  local thread = coroutine.running()
  gopls:request("workspace/symbol", { query = "main" }, function(err, result, _, _)
    if err then
      return coroutine.resume(thread, err.message)
    end
    local files = {}
    local workspaceDir = vim.uri_to_fname(gopls.workspace_folders[1].uri)
    for _, item in ipairs(result) do
      if item.name == "main" and item.kind == vim.lsp.protocol.SymbolKind.Function then
        local fname = vim.uri_to_fname(item.location.uri)
        table.insert(files, fname:sub(#workspaceDir + 2))
      end
    end
    return coroutine.resume(thread, nil, files)
  end)
  local err, files = coroutine.yield()
  if err then
    return "Error finding files with main functions: " .. err, {}
  end
  if not files or vim.tbl_isempty(files) then
    return nil, {}
  end
  return nil, files
end

local function select_main_file()
  return coroutine.create(function(dap_run_co)
    local dap = require('dap')
    local err, files = find_main_files()
    if err then
      vim.notify(err, vim.log.levels.ERROR)
      return coroutine.resume(dap_run_co, dap.ABORT)
    end
    vim.ui.select(files, { prompt = "Select file containing main function" }, function(choice)
      coroutine.resume(dap_run_co, choice or dap.ABORT)
    end)
  end)
end

local function getargs()
  return require('dap-go').get_arguments()
end

---@type dap.Configuration[]
local extra_launch_configs = {
  {
    type = "go",
    name = "Debug main",
    request = "launch",
    program = select_main_file,
  },
  {
    type = "go",
    name = "Debug main (Arguments)",
    request = "launch",
    program = select_main_file,
    args = getargs,
  },
  {
    type = "go",
    name = "Replay last rr recording",
    request = "launch",
    mode = "replay",
    traceDirPath = vim.fn.expand("~/.local/share/rr/latest-trace"),
  },
  {
    type = "go",
    name = "Debug package (Arguments)",
    request = "launch",
    program = "${fileDirname}",
    args = getargs,
  },
}

---@type table[]
local mappings_backups = {}
local function restore_mappings()
  for _, backup in ipairs(mappings_backups) do
    vim.fn.mapset(backup)
  end
  mappings_backups = {}
end

---@alias KeyMapper fun(modes: string|string[], lhs: string|string[], rhs: any, opts: any)

--- Sets a keymap and backup any existing mapping
---@type KeyMapper
local function set(modes, lhs, rhs, opts)
  opts = opts or {}
  ---@cast modes string[]
  modes = type(modes) == 'string' and { modes } or modes
  ---@cast lhs string[]
  lhs = type(lhs) == 'string' and { lhs } or lhs
  for _, mode in ipairs(modes) do
    for _, name in ipairs(lhs) do
      local existing_mapping = vim.fn.maparg(name, mode, false, true)
      if not vim.tbl_isempty(existing_mapping) then
        -- Backup existing mapping, restore later when DAP session ends
        table.insert(mappings_backups, existing_mapping)
      end
      vim.keymap.set(mode, name, rhs, opts)
    end
  end
end

local function on_session(old, new)
  local dap = require('dap')

  ---@type ProgressHandle|nil
  local progress
  dap.listeners.before.initialize.duboisf = function()
    local fidget = require('fidget')
    progress = fidget.progress.handle.create({
      title = "DAP",
      message = "Starting debug session...",
    })
  end

  dap.listeners.after.launch.duboisf = function()
    if progress ~= nil then
      progress:finish()
      progress = nil
    end
  end

  ---@type KeyMapper|nil
  local toggle
  if new then
    toggle = set
  elseif old then
    toggle = function(mode, lhs, _, _)
      vim.keymap.del(mode, lhs)
    end
  end
  if not toggle then
    return
  end
  toggle('n', '<leader>dt', function()
    dap.terminate()
  end)
  toggle('n', '<C-down>', dap.down)
  toggle('n', '<C-up>', dap.up)
  toggle('n', '<down>', dap.step_over)
  toggle('n', '<up>', dap.step_back)
  toggle('n', '<C-S-up>', dap.reverse_continue)
  toggle('n', '<right>', dap.step_into)
  toggle('n', '<left>', dap.step_out)
  toggle({ 'n', 'v' }, '<C-h>', require('dap.ui.widgets').hover)
  toggle({ 'n', 'v' }, '<C-p>', require('dap.ui.widgets').preview)
  toggle('n', '<leader>lf',
    function()
      local widgets = require('dap.ui.widgets')
      widgets.centered_float(widgets.frames)
    end, { desc = 'Debug Go Test' })
  toggle('n', '<leader>ds',
    function()
      local widgets = require('dap.ui.widgets')
      widgets.centered_float(widgets.scopes)
    end)
  if old then
    restore_mappings()
  end
end

return {
  {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require('dap')

      dap.listeners.on_session["duboisf"] = vim.schedule_wrap(on_session)

      create_autocmds()

      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Dap Continue' })
      vim.keymap.set('n', '<C-S-down>', dap.continue, { desc = 'Dap Continue' })
      vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Dap Run Last' })
      vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Dap Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Dap Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        ---@diagnostic disable-next-line: undefined-global
        Snacks.input.input(nil, function(msg)
          dap.toggle_breakpoint(nil, nil, msg)
        end)
      end, { desc = 'Dap Toggle Logpoint' })
      vim.keymap.set('n', '<leader>td', function() require('dap-go').debug_test() end,
        { desc = 'Dap Debug Current Go Test' })
      vim.keymap.set('n', '<leader>du', function() require('dapui').toggle({ reset = true }) end,
        { desc = 'Dap Toggle UI' })
      vim.fn.sign_define('DapBreakpoint', {
        text = '🔴',
        texthl = '',
        linehl = 'DapBreakpointLine',
        numhl = ''
      })

      vim.fn.sign_define('DapStopped', {
        text = '🠊',
        texthl = '',
        linehl = 'DapStoppedLine',
        numhl = ''
      })
    end,
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'folke/snacks.nvim',
      'j-hui/fidget.nvim',
    },
  },
  {
    'rcarriga/nvim-dap-ui',
    opts = {
      layouts = {
        {
          elements = { "scopes" },
          size = 15,
          position = "top",
        },
        {
          elements = {
            -- Provide IDs as strings or tables with "id" and "size" keys
            { id = "stacks",      size = 0.25 },
            { id = "watches",     size = 0.25 },
            { id = "breakpoints", size = 0.25 },
          },
          size = 40,
          position = "right",
        },
        {
          elements = { "repl" },
          size = 10,
          position = "bottom",
        },
      },
    },
  },
  {
    'leoluz/nvim-dap-go',
    opts = {
      dap_configurations = extra_launch_configs,
    },
    ft = { 'go' },
  },
  {
    'suketa/nvim-dap-ruby',
    config = true,
    ft = { 'ruby' },
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    opts = {
      all_references = true,
      commented = true,
      virt_text_win_col = 80,
    },
  },
}
