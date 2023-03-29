return {
  'github/copilot.vim',
  config = function()
    -- Do not let copilot.vim map the <TAB> key, handle it in nvim-cmp's config
    -- Ref: https://github.com/hrsh7th/nvim-cmp/blob/b16e5bcf1d8fd466c289eab2472d064bcd7bab5d/doc/cmp.txt#L830-L852
    vim.g.copilot_no_tab_map = true
    vim.keymap.set(
        'i',
        '<Plug>(vimrc:copilot-dummy-map)',
        'copilot#Accept("")',
        { silent = true, expr = true, desc = 'Copilot dummy accept' }
    )
    -- use <C-,> to accept the suggestion, weird choice but I don't have many options left
    vim.keymap.set('i', '<C-,>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
  end
}
