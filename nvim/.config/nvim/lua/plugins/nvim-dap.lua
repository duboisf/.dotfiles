return {
  {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require 'dap'
      vim.keymap.set('n', '<F5>', dap.continue)
      vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
      vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
      vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
      vim.keymap.set('n', '<F9>', function() require('dap').toggle_breakpoint() end)
      vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
      vim.keymap.set('n', '<Leader>lp',
        function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
      vim.keymap.set('n', '<Leader>td', function()
        require('dap-go').debug_test()
        vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
        vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
        vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function() require('dap.ui.widgets').hover() end)
        vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function() require('dap.ui.widgets').preview() end)
        vim.keymap.set('n', '<Leader>df',
          function()
            local widgets = require('dap.ui.widgets')
            widgets.centered_float(widgets.frames)
          end, { desc = 'Debug Go Test' })
        vim.keymap.set('n', '<Leader>ds',
          function()
            local widgets = require('dap.ui.widgets')
            widgets.centered_float(widgets.scopes)
          end)
      end)
    end,
    dependencies = { 'nvim-neotest/nvim-nio' },
  },
  {
    'rcarriga/nvim-dap-ui',
    config = true,
  },
  {
    'leoluz/nvim-dap-go',
    config = true,
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
