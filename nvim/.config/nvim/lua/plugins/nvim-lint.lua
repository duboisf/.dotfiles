local get_golangcilint_cmd = function()
  local cwd = vim.fn.getcwd()
  local custom_gcl = cwd .. '/custom-gcl'
  if vim.fn.executable(custom_gcl) == 1 then
    return custom_gcl
  else
    return 'golangci-lint'
  end
end

---@type LazyPluginSpec
return {
  "mfussenegger/nvim-lint",
  enabled = false,
  config = function(_, _)
    local lint = require('lint')
    local golangcilint = lint.linters.golangcilint
    -- if there is an executable called 'custom-gcl' at the root of the project, use it instead
    golangcilint.cmd = get_golangcilint_cmd()
    print("Using golangci-lint command: " .. golangcilint.cmd)
    lint.linters_by_ft = {
      go = { 'golangcilint' },
    }
    local augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
      group = augroup,
      callback = function()
        lint.try_lint()
      end,
    })
  end
}
