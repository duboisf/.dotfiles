local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local home = os.getenv('HOME')
local config = {
  cmd = {
    '/usr/lib/jvm/jdk-23.0.1-oracle-x64/bin/java', -- or '/path/to/java21_or_newer/bin/java'
    -- depends on if `java` is in your $PATH env variable and if it points to the right version.

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx2g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

    '-javaagent:' .. home .. '/Downloads/lombok.jar',

    -- 💀
    '-jar', home ..
  '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar',

    -- 💀
    '-configuration', home .. '/.local/share/nvim/mason/packages/jdtls/config_linux',

    -- 💀
    -- See `data directory configuration` section in the README
    '-data', '/tmp/jdtls-' .. project_name,
  },
  root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git' }, { upwared = true })[1]),
}

local border = {
  { "🭽", "FloatBorder" },
  { "▔", "FloatBorder" },
  { "🭾", "FloatBorder" },
  { "▕", "FloatBorder" },
  { "🭿", "FloatBorder" },
  { "▁", "FloatBorder" },
  { "🭼", "FloatBorder" },
  { "▏", "FloatBorder" },
}

do
  local normal_mappings = {
    [',s']         = '<cmd>Telescope lsp_document_symbols<CR>',
    [',w']         = '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>',
    ['<leader>cl'] = '<cmd>lua vim.lsp.codelens.run()<CR>',
    ['<leader>ca'] = '<cmd>lua vim.lsp.buf.code_action()<CR>',
    ['<leader>d']  = '<cmd>lua vim.diagnostic.open_float()<CR>',
    ['<leader>rn'] = '<cmd>lua vim.lsp.buf.rename()<CR>',
    ['K']          = '<Cmd>lua vim.lsp.buf.hover()<CR>',
    ['[d']         = '<cmd>lua vim.diagnostic.goto_prev()<CR>',
    [']d']         = '<cmd>lua vim.diagnostic.goto_next()<CR>',
    ['gD']         = '<Cmd>lua vim.lsp.buf.type_definition()<CR>',
    ['gd']         = '<Cmd>Telescope lsp_definitions<CR>',
    ['gi']         = '<cmd>Telescope lsp_implementations<CR>',
    ['gr']         = '<cmd>Telescope lsp_references<CR>',
  }

  local bufnr = vim.api.nvim_get_current_buf()
  local opts = { noremap = true, silent = true, buffer = bufnr }

  for lhs, rhs in pairs(normal_mappings) do
    vim.keymap.set('n', lhs, rhs, opts)
  end

  for _, mode in ipairs({ 'i' }) do
    -- TODO: check if the language server supports signature help before adding this mapping
    vim.keymap.set(mode, '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  end
end

require('jdtls').start_or_attach(config)

local orig_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_open_floating_preview(contents, syntax, opts, ...)
end
