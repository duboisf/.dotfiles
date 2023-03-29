return {
  'github/copilot.vim',
  config = function()
    -- do not remap <TAB> key, we add a binding for copilot in the nvim-cmp plugin
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true

    -- use <C-,> to accept the suggestion, weird choice but I don't have many options left
    vim.keymap.set('i', '<C-,>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
  end
}
