return {
  {
    'mfussenegger/nvim-dap',
    config = function()
      ---@type table[]
      local mappings_backups = {}
      local function restore_mappings()
        for _, backup in ipairs(mappings_backups) do
          vim.fn.mapset(backup)
        end
        mappings_backups = {}
      end

      --- Sets a keymap and backup any existing mapping
      ---@param modes string|string[]
      ---@param lhs string|string[]
      ---@param rhs any
      ---@param opts any
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

      local dap = require('dap')
      dap.listeners.on_session["duboisf"] = vim.schedule_wrap(function(old, new)
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
        toggle('n', '<leader>do', function() require('dapui').toggle({ reset = true }) end)
        toggle('n', '<leader>dt', function()
          dap.terminate()
          require('dapui').close()
        end)
        toggle('n', '<C-down>', dap.down)
        toggle('n', '<C-up>', dap.up)
        toggle('n', '<down>', dap.step_over)
        toggle('n', '<up>', dap.step_back)
        toggle('n', '<right>', dap.step_into)
        toggle('n', '<left>', dap.step_out)
        toggle('n', '<leader>dr', dap.reverse_continue)
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
      end)

      vim.keymap.set('n', '<F5>', dap.continue)
      vim.keymap.set('n', '<leader>dd', dap.continue)
      vim.keymap.set('n', '<leader>dl', function() require('dap').run_last() end)
      vim.keymap.set('n', '<F9>', dap.toggle_breakpoint)
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint)
      vim.keymap.set('n', '<leader>dt', function() require('dap-go').debug_test() end)
    end,
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui'
    },
  },
  {
    'rcarriga/nvim-dap-ui',
    config = {
      icons = { expanded = "", collapsed = "", current_frame = "" },
      mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      element_mappings = {},
      expand_lines = vim.fn.has("nvim-0.7") == 1,
      force_buffers = true,
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
      floating = {
        max_height = nil,
        max_width = nil,
        border = "single",
        mappings = {
          ["close"] = { "q", "<Esc>" },
        },
      },
      controls = {
        enabled = vim.fn.exists("+winbar") == 1,
        element = "repl",
        icons = {
          pause = "",
          play = "",
          step_into = "",
          step_over = "",
          step_out = "",
          step_back = "",
          run_last = "",
          terminate = "",
          disconnect = "",
        },
      },
      render = {
        max_type_length = nil, -- Can be integer or nil.
        max_value_lines = 100, -- Can be integer or nil.
        indent = 1,
      },
    },
  },
  {
    'leoluz/nvim-dap-go',
    config = {
      dap_configurations = {
        {
          -- Must be "go" or it will be ignored by the plugin
          type = "go",
          name = "replay",
          request = "launch",
          mode = "replay",
          traceDirPath = vim.fn.expand("~/.local/share/rr/latest-trace"),
        },
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
