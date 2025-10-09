---@type dap.Configuration
local rr_replay_launch_config = {
  type = "go",
  name = "Replay last rr recording",
  request = "launch",
  mode = "replay",
  traceDirPath = vim.fn.expand("~/.local/share/rr/latest-trace"),
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

  ---@type KeyMapper|nil
  local toggle
  if new then
    toggle = set
  elseif old then
    require('dapui').close()
    toggle = function(mode, lhs, _, _)
      vim.keymap.del(mode, lhs)
    end
  end
  if not toggle then
    return
  end
  toggle('n', '<leader>do', function() require('dapui').toggle({ reset = true }) end)
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

      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Dap Continue' })
      vim.keymap.set('n', '<C-S-down>', dap.continue, { desc = 'Dap Continue' })
      vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Dap Run Last' })
      vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Dap Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Dap Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>dt', function() require('dap-go').debug_test() end,
        { desc = 'Dap Debug Current Go Test' })
      vim.keymap.set('n', '<leader>dc', function() require('dapui').close() end, { desc = 'Dap Close UI' })

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
      'rcarriga/nvim-dap-ui'
    },
  },
  {
    'rcarriga/nvim-dap-ui',
    opts = {
      layouts = {
        {
          elements = {
            "scopes",
          },
          size = 10,
          position = "top", -- Can be "left" or "right"
        },
        {
          -- You can change the order of elements in the sidebar
          elements = {
            -- Provide IDs as strings or tables with "id" and "size" keys
            { id = "breakpoints", size = 0.25 },
            { id = "stacks",      size = 0.25 },
            { id = "watches",     size = 0.25 },
          },
          size = 40,
          position = "left", -- Can be "left" or "right"
        },
        {
          elements = {
            "repl",
            "console",
          },
          size = 10,
          position = "bottom", -- Can be "bottom" or "top"
        },
      },
    },
  },
  {
    'leoluz/nvim-dap-go',
    opts = {
      dap_configurations = {
        rr_replay_launch_config,
      },
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
    config = true,
  },
}
